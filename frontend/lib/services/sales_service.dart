import '../models/product.dart';
import '../models/sale.dart';
import 'supabase_client.dart';

class CartLine {
  final Product product;
  int qty;
  CartLine({required this.product, this.qty = 1});
  double get subtotal => product.price * qty;
}

class SalesService {
  final _client = SupabaseClientProvider.client;

  Future<List<Sale>> fetchAll({int limit = 60}) async {
    final ownerId = SupabaseClientProvider.currentUserId;
    final rows = await _client
        .from('sales')
        .select('*, sale_items(*)')
        .eq('owner_id', ownerId as Object)
        .order('sold_at', ascending: false)
        .limit(limit);
    return (rows as List).map((e) => Sale.fromMap(e as Map<String, dynamic>)).toList();
  }

  /// Registra la venta completa de forma atómica en el servidor
  /// (descuenta stock y crea sale_items en una sola transacción),
  /// vía la función RPC `register_sale` definida en el backend.
  Future<String> registerSale({
    required List<CartLine> lines,
    required String paymentMethod,
  }) async {
    final items = lines
        .map((l) => {'product_id': l.product.id, 'qty': l.qty})
        .toList();
    final result = await _client.rpc('register_sale', params: {
      'p_items': items,
      'p_payment_method': paymentMethod,
    });
    return result as String;
  }
}
