import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/sale.dart';
import '../../../widgets/app_bottom_sheet.dart';

class SaleDetailSheet extends StatelessWidget {
  final Sale sale;
  const SaleDetailSheet({super.key, required this.sale});

  static Future<void> open(BuildContext context, Sale sale) {
    return SpicyBottomSheet.show(context, title: 'Detalle de venta', child: SaleDetailSheet(sale: sale));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('${Formatters.shortDateTime(sale.soldAt)} · ${sale.paymentMethod}',
            style: AppTypography.label.copyWith(color: c.textSecondary)),
        const SizedBox(height: AppSpacing.md),
        ...sale.items.map((it) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(child: Text('${it.qty}× ${it.productName}', style: AppTypography.body.copyWith(color: c.textPrimary))),
                  Text(Formatters.money(it.subtotal), style: AppTypography.bodyMedium.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
                ],
              ),
            )),
        const Divider(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total', style: AppTypography.body.copyWith(color: c.textSecondary)),
            Text(Formatters.money(sale.total), style: AppTypography.metric.copyWith(color: c.textPrimary)),
          ],
        ),
      ],
    );
  }
}
