class Expense {
  final String id;
  final String category;
  final String? description;
  final double amount;
  final DateTime expenseDate;

  const Expense({
    required this.id,
    required this.category,
    this.description,
    required this.amount,
    required this.expenseDate,
  });

  factory Expense.fromMap(Map<String, dynamic> m) => Expense(
        id: m['id'] as String,
        category: m['category'] as String? ?? 'Otro',
        description: m['description'] as String?,
        amount: (m['amount'] as num?)?.toDouble() ?? 0,
        expenseDate: DateTime.parse(m['expense_date'] as String),
      );

  Map<String, dynamic> toInsertMap({required String ownerId}) => {
        'owner_id': ownerId,
        'category': category,
        'description': description,
        'amount': amount,
      };
}
