import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/sale.dart';

class SaleDetailSheet extends StatelessWidget {
  final Sale sale;
  const SaleDetailSheet({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('${Formatters.shortDateTime(sale.soldAt)} · ${sale.paymentMethod}',
            style: const TextStyle(color: AppColors.asphalt, fontSize: 12.5)),
        const SizedBox(height: 12),
        ...sale.items.map((it) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Text('${it.qty}× ${it.productName}', style: const TextStyle(fontSize: 13))),
                  Text(Formatters.money(it.subtotal), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
            )),
        const Divider(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total', style: TextStyle(color: AppColors.asphalt)),
            Text(Formatters.money(sale.total), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
          ],
        ),
      ],
    );
  }
}