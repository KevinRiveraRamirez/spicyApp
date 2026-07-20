import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/expense.dart';
import '../../../models/purchase.dart';
import '../../../models/sale.dart';

class IncomeExpenseChart extends StatelessWidget {
  final List<Sale> sales;
  final List<Expense> expenses;
  final List<Purchase> purchases;

  const IncomeExpenseChart({super.key, required this.sales, required this.expenses, required this.purchases});

  @override
  Widget build(BuildContext context) {
    final income = <double>[];
    final outcome = <double>[];
    for (int w = 5; w >= 0; w--) {
      final start = DateTime.now().subtract(Duration(days: w * 7 + 6));
      final end = DateTime.now().subtract(Duration(days: w * 7));
      bool inRange(DateTime d) {
        final day = DateTime(d.year, d.month, d.day);
        return !day.isBefore(DateTime(start.year, start.month, start.day)) &&
            !day.isAfter(DateTime(end.year, end.month, end.day));
      }

      income.add(sales.where((s) => inRange(s.soldAt)).fold(0.0, (a, s) => a + s.total));
      outcome.add(expenses.where((e) => inRange(e.expenseDate)).fold(0.0, (a, e) => a + e.amount) +
          purchases.where((p) => inRange(p.orderedAt)).fold(0.0, (a, p) => a + p.total));
    }
    final maxVal = [...income, ...outcome].fold(10.0, (a, b) => a > b ? a : b) * 1.2;

    return SizedBox(
      height: 170,
      child: BarChart(
        BarChartData(
          maxY: maxVal,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('S${v.toInt() + 1}', style: const TextStyle(fontSize: 9, color: AppColors.asphalt)),
                ),
              ),
            ),
          ),
          barGroups: [
            for (int i = 0; i < 6; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(toY: income[i], color: AppColors.success, width: 7, borderRadius: BorderRadius.circular(4)),
                BarChartRodData(toY: outcome[i], color: AppColors.spicyRed, width: 7, borderRadius: BorderRadius.circular(4)),
              ]),
          ],
        ),
      ),
    );
  }
}
