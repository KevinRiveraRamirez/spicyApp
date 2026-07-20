import '../models/expense.dart';
import 'supabase_client.dart';

class ExpenseService {
  final _client = SupabaseClientProvider.client;

  Future<List<Expense>> fetchAll({int limit = 60}) async {
    final ownerId = SupabaseClientProvider.currentUserId;
    final rows = await _client
        .from('expenses')
        .select()
        .eq('owner_id', ownerId as Object)
        .order('expense_date', ascending: false)
        .limit(limit);
    return (rows as List).map((e) => Expense.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<Expense> create(Expense expense) async {
    final ownerId = SupabaseClientProvider.currentUserId!;
    final row = await _client
        .from('expenses')
        .insert(expense.toInsertMap(ownerId: ownerId))
        .select()
        .single();
    return Expense.fromMap(row);
  }

  Future<void> delete(String expenseId) async {
    await _client.from('expenses').delete().eq('id', expenseId);
  }
}
