import '../../models/expense.dart';
import '../../models/product.dart';
import '../../models/purchase.dart';
import '../../models/sale.dart';

/// Cálculos de métricas de negocio, compartidos entre Dashboard y Finanzas.
class Metrics {
  Metrics._();

  static bool _inLastDays(DateTime date, int days) {
    final from = DateTime.now().subtract(Duration(days: days - 1));
    final d = DateTime(date.year, date.month, date.day);
    final f = DateTime(from.year, from.month, from.day);
    return !d.isBefore(f);
  }

  static List<Sale> salesInLastDays(List<Sale> sales, int days) =>
      sales.where((s) => _inLastDays(s.soldAt, days)).toList();

  static List<Expense> expensesInLastDays(List<Expense> expenses, int days) =>
      expenses.where((e) => _inLastDays(e.expenseDate, days)).toList();

  static double sumSales(List<Sale> sales) =>
      sales.fold(0, (a, s) => a + s.total);

  static double sumExpenses(List<Expense> expenses) =>
      expenses.fold(0, (a, e) => a + e.amount);

  static double sumPurchases(List<Purchase> purchases, int days) => purchases
      .where((p) => _inLastDays(p.orderedAt, days))
      .fold(0, (a, p) => a + p.total);

  static List<Product> lowStock(List<Product> products) =>
      products.where((p) => p.stock <= p.minStock).toList();

  static double netProfit({
    required List<Sale> sales,
    required List<Expense> expenses,
    required List<Purchase> purchases,
    int days = 30,
  }) {
    final rev = sumSales(salesInLastDays(sales, days));
    final exp = sumExpenses(expensesInLastDays(expenses, days));
    final purch = sumPurchases(purchases, days);
    return rev - exp - purch;
  }

  static double averageTicket(List<Sale> sales) {
    if (sales.isEmpty) return 0;
    return sumSales(sales) / sales.length;
  }

  /// Top productos vendidos por cantidad, en los últimos [days] días.
  static List<MapEntry<String, int>> topProducts(List<Sale> sales, {int days = 30, int limit = 5}) {
    final recent = salesInLastDays(sales, days);
    final map = <String, int>{};
    for (final s in recent) {
      for (final it in s.items) {
        map[it.productName] = (map[it.productName] ?? 0) + it.qty;
      }
    }
    final entries = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList();
  }

  /// Ventas por día para los últimos [days] días (para la gráfica de tendencia).
  static List<double> dailyTrend(List<Sale> sales, {int days = 14}) {
    final result = <double>[];
    for (int i = days - 1; i >= 0; i--) {
      final day = DateTime.now().subtract(Duration(days: i));
      final total = sales
          .where((s) =>
              s.soldAt.year == day.year && s.soldAt.month == day.month && s.soldAt.day == day.day)
          .fold(0.0, (a, s) => a + s.total);
      result.add(total);
    }
    return result;
  }
}
