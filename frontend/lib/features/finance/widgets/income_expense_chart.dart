import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/expense.dart';
import '../../../models/purchase.dart';
import '../../../models/sale.dart';

/// Ingresos (ventas) vs. gastos (compras + gastos manuales) por
/// semana, con leyenda, tooltip al tocar una barra, y rango de tiempo
/// configurable (6 o 12 semanas).
class IncomeExpenseChart extends StatelessWidget {
  final List<Sale> sales;
  final List<Expense> expenses;
  final List<Purchase> purchases;
  final int weeks;

  const IncomeExpenseChart({
    super.key,
    required this.sales,
    required this.expenses,
    required this.purchases,
    this.weeks = 6,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final income = <double>[];
    final outcome = <double>[];
    for (int w = weeks - 1; w >= 0; w--) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _LegendDot(color: c.success, label: 'Ingresos'),
            const SizedBox(width: AppSpacing.lg),
            _LegendDot(color: c.danger, label: 'Gastos'),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 170,
          child: BarChart(
            BarChartData(
              maxY: maxVal,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => c.textPrimary,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                    Formatters.money(rod.toY),
                    TextStyle(color: c.background, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, meta) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('S${v.toInt() + 1}', style: AppTypography.label.copyWith(fontSize: 9, color: c.textSecondary)),
                    ),
                  ),
                ),
              ),
              barGroups: [
                for (int i = 0; i < weeks; i++)
                  BarChartGroupData(x: i, barRods: [
                    BarChartRodData(toY: income[i], color: c.success, width: 7, borderRadius: BorderRadius.circular(4)),
                    BarChartRodData(toY: outcome[i], color: c.danger, width: 7, borderRadius: BorderRadius.circular(4)),
                  ]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.label.copyWith(color: c.textSecondary)),
      ],
    );
  }
}
