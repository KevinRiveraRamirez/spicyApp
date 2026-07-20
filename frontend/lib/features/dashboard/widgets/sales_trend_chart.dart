import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SalesTrendChart extends StatelessWidget {
  final List<double> values; // últimos N días, orden cronológico

  const SalesTrendChart({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
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
          lineTouchData: const LineTouchData(enabled: true),
          lineBarsData: [
            LineChartBarData(
              spots: [for (int i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])],
              isCurved: true,
              color: AppColors.spicyRed,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.spicyRed.withOpacity(.32), AppColors.spicyRed.withOpacity(0)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
