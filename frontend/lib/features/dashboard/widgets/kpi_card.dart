import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String? delta;
  final bool positive;

  const KpiCard({super.key, required this.label, required this.value, this.delta, this.positive = true});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 19)),
          if (delta != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: (positive ? AppColors.success : AppColors.spicyRed).withOpacity(.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(delta!,
                  style: TextStyle(
                      color: positive ? AppColors.success : AppColors.spicyRed,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}
