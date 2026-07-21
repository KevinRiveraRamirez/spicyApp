import '../models/supplier.dart';
import 'supabase_client.dart';

class SupplierService {
  final _client = SupabaseClientProvider.client;

  Future<List<Supplier>> fetchAll() async {
    final ownerId = SupabaseClientProvider.currentUserId;
    final rows = await _client
        .from('suppliers')
        .select()
        .eq('owner_id', ownerId as Object)
        .order('name');
    return (rows as List).map((e) => Supplier.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<Supplier> create(Supplier supplier) async {
    final ownerId = SupabaseClientProvider.currentUserId!;
    final row = await _client
        .from('suppliers')
        .insert(supplier.toInsertMap(ownerId: ownerId))
        .select()
        .single();
    return Supplier.fromMap(row);
  }

  /// Las órdenes de compra ya hechas no se borran: `purchases.supplier_id`
  /// queda en null (conserva `supplier_name` como snapshot histórico).
  Future<void> delete(String id) async {
    await _client.from('suppliers').delete().eq('id', id);
  }
}