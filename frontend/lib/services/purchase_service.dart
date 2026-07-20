import '../models/product.dart';
import '../models/purchase.dart';
import 'supabase_client.dart';

class PurchaseLine {
  final Product product;
  int qty;
  PurchaseLine({required this.product, this.qty = 1});
  double get subtotal => product.cost * qty;
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

  Future<void> create({
    required String supplierId,
    required String supplierName,
    required List<PurchaseLine> lines,
  }) async {
    final ownerId = SupabaseClientProvider.currentUserId!;
    final total = lines.fold<double>(0, (a, l) => a + l.subtotal);

    final purchase = await _client
        .from('purchases')
        .insert({
          'owner_id': ownerId,
          'supplier_id': supplierId,
          'supplier_name': supplierName,
          'status': 'Pendiente',
          'total': total,
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
              'cost': l.product.cost,
            })
        .toList());
  }

  /// Marca la orden como recibida y suma el stock de forma atómica
  /// vía la función RPC `receive_purchase`.
  Future<void> receive(String purchaseId) async {
    await _client.rpc('receive_purchase', params: {'p_purchase_id': purchaseId});
  }
}
