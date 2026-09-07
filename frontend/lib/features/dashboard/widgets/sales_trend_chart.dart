import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';

/// Tendencia de ventas de los últimos N días, con selección táctil:
/// tocar un punto muestra el monto de ese día en un tooltip.
class SalesTrendChart extends StatelessWidget {
  final List<double> values; // últimos N días, orden cronológico

  const SalesTrendChart({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final maxY = values.isEmpty ? 100.0 : (values.reduce((a, b) => a > b ? a : b) * 1.2).clamp(10, double.infinity);
    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY.toDouble(),
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => c.textPrimary,
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        Formatters.money(s.y),
                        TextStyle(color: c.background, fontSize: 11, fontWeight: FontWeight.w700),
                      ))
                  .toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [for (int i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])],
              isCurved: true,
              color: c.brandPrimary,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [c.brandPrimary.withOpacity(.28), c.brandPrimary.withOpacity(0)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
