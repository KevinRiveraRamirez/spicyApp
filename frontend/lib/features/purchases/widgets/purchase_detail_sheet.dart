import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/purchase.dart';
import '../../../state/app_state.dart';

class PurchaseDetailSheet extends StatefulWidget {
  final Purchase purchase;
  const PurchaseDetailSheet({super.key, required this.purchase});

  @override
  State<PurchaseDetailSheet> createState() => _PurchaseDetailSheetState();
}

class _PurchaseDetailSheetState extends State<PurchaseDetailSheet> {
  bool _receiving = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.purchase;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('${p.supplierName} · ${Formatters.shortDate(p.orderedAt)}',
            style: const TextStyle(color: AppColors.asphalt, fontSize: 12.5)),
        const SizedBox(height: 12),
        ...p.items.map((it) => Padding(
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
            Text(Formatters.money(p.total), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
          ],
        ),
        const SizedBox(height: 14),
        if (p.status == PurchaseStatus.pendiente)
          ElevatedButton(
            onPressed: _receiving
                ? null
                : () async {
                    setState(() => _receiving = true);
                    try {
                      await context.read<AppState>().receivePurchase(p.id);
                      if (mounted) Navigator.of(context).pop();
                    } finally {
                      if (mounted) setState(() => _receiving = false);
                    }
                  },
            child: _receiving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('MARCAR COMO RECIBIDA'),
          )
        else
          const Text('✅ Mercancía recibida', style: TextStyle(color: AppColors.asphalt, fontSize: 12.5)),
      ],
    );
  }
}
