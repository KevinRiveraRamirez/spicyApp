import '../models/product.dart';
import 'supabase_client.dart';

class ProductService {
  final _client = SupabaseClientProvider.client;

  Future<List<Product>> fetchAll() async {
    final ownerId = SupabaseClientProvider.currentUserId;
    final rows = await _client
        .from('products')
        .select()
        .eq('owner_id', ownerId as Object)
        .order('name');
    return (rows as List).map((e) => Product.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<Product> create(Product product) async {
    final ownerId = SupabaseClientProvider.currentUserId!;
    final row = await _client
        .from('products')
        .insert(product.toInsertMap(ownerId: ownerId))
        .select()
        .single();
    return Product.fromMap(row);
  }

  Future<Product> update(Product product) async {
    final ownerId = SupabaseClientProvider.currentUserId!;
    final row = await _client
        .from('products')
        .update(product.toInsertMap(ownerId: ownerId))
        .eq('id', product.id)
        .select()
        .single();
    return Product.fromMap(row);
  }

  Future<void> delete(String productId) async {
    await _client.from('products').delete().eq('id', productId);
  }
}
