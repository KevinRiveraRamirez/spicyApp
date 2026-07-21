import '../models/product.dart';
import '../models/purchase.dart';
import 'supabase_client.dart';

class PurchaseLine {
  final Product product;
  int qty;
  /// Costo por unidad — en dólares si el proveedor es extranjero
  /// (China/Estados Unidos), en colones directo si es de Costa Rica.
  /// Independiente de `product.cost` (costo base usado para márgenes),
  /// porque el precio real de compra varía por orden/proveedor.
  double cost;

  PurchaseLine({required this.product, this.qty = 1, this.cost = 0});

  double get subtotal => qty * cost;
}

class PurchaseService {
  final _client = SupabaseClientProvider.client;

  Future<List<Purchase>> fetchAll() async {
    final ownerId = SupabaseClientProvider.currentUserId;
    final rows = await _client
        .from('purchases')
        .select('*, purchase_items(*)')
        .eq('owner_id', ownerId as Object)
        .order('ordered_at', ascending: false);
    return (rows as List).map((e) => Purchase.fromMap(e as Map<String, dynamic>)).toList();
  }

  /// [currency]: 'USD' (proveedor de China/Estados Unidos, aplica
  /// [exchangeRate]) o 'CRC' (proveedor de Costa Rica, todo directo en
  /// colones, sin conversión — [exchangeRate] se ignora).
  Future<void> create({
    required String supplierId,
    required String supplierName,
    required List<PurchaseLine> lines,
    required String currency,
    double exchangeRate = 1,
  }) async {
    final ownerId = SupabaseClientProvider.currentUserId!;
    final isUsd = currency == 'USD';
    final rate = isUsd ? exchangeRate : 1.0;
    final totalUsd = isUsd ? lines.fold<double>(0, (a, l) => a + l.subtotal) : 0.0;
    final total = isUsd ? totalUsd * rate : lines.fold<double>(0, (a, l) => a + l.subtotal);

    final purchase = await _client
        .from('purchases')
        .insert({
          'owner_id': ownerId,
          'supplier_id': supplierId,
          'supplier_name': supplierName,
          'status': 'Pedido',
          'total': total,
          'total_usd': totalUsd,
          'exchange_rate': rate,
          'currency': currency,
        })
        .select()
        .single();

    final purchaseId = purchase['id'] as String;
    await _client.from('purchase_items').insert(lines
        .map((l) => {
              'purchase_id': purchaseId,
              'product_id': l.product.id,
              'product_name': l.product.name,
              'qty': l.qty,
              'cost': isUsd ? l.cost * rate : l.cost,
              'cost_usd': isUsd ? l.cost : 0,
            })
        .toList());
  }

  /// Marca la orden como "En tránsito" (ya salió del proveedor rumbo a CR).
  Future<void> markInTransit(String purchaseId) async {
    await _client.from('purchases').update({'status': 'En tránsito'}).eq('id', purchaseId);
  }

  /// Marca la orden como recibida y suma el stock de forma atómica
  /// vía la función RPC `receive_purchase`.
  Future<void> receive(String purchaseId) async {
    await _client.rpc('receive_purchase', params: {'p_purchase_id': purchaseId});
  }
}