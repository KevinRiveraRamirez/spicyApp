import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/purchase.dart';
import '../../../state/app_state.dart';
import '../../../widgets/item_row.dart';

class PurchaseDetailSheet extends StatefulWidget {
  final Purchase purchase;
  const PurchaseDetailSheet({super.key, required this.purchase});

  @override
  State<PurchaseDetailSheet> createState() => _PurchaseDetailSheetState();
}

class _PurchaseDetailSheetState extends State<PurchaseDetailSheet> {
  bool _working = false;

  Color _statusColor(PurchaseStatus s) => switch (s) {
        PurchaseStatus.pedido => AppColors.asphalt,
        PurchaseStatus.enTransito => AppColors.info,
        PurchaseStatus.recibida => AppColors.success,
      };

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _working = true);
    try {
      await action();
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.purchase;
    final color = _statusColor(p.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text('${p.supplierName} · ${Formatters.shortDate(p.orderedAt)}',
                  style: const TextStyle(color: AppColors.asphalt, fontSize: 12.5)),
            ),
            StatusChip(label: p.status.label, color: color, background: color.withOpacity(.12)),
          ],
        ),
        const SizedBox(height: 12),
        ...p.items.map((it) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Text('${it.qty}× ${it.productName}', style: const TextStyle(fontSize: 13))),
                  if (p.isUsd)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(Formatters.usd(it.subtotalUsd), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        Text(Formatters.money(it.subtotal), style: const TextStyle(fontSize: 11, color: AppColors.asphalt)),
                      ],
                    )
                  else
                    Text(Formatters.money(it.subtotal), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
            )),
        const Divider(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total', style: TextStyle(color: AppColors.asphalt)),
            if (p.isUsd)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Formatters.usd(p.totalUsd), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                  Text('${Formatters.money(p.total)} · tipo de cambio ₡${p.exchangeRate.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.asphalt)),
                ],
              )
            else
              Text(Formatters.money(p.total), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
          ],
        ),
        const SizedBox(height: 14),
        if (p.status == PurchaseStatus.pedido)
          ElevatedButton(
            onPressed: _working ? null : () => _run(() => context.read<AppState>().markPurchaseInTransit(p.id)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.info),
            child: _working
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('MARCAR EN TRÁNSITO'),
          )
        else if (p.status == PurchaseStatus.enTransito)
          ElevatedButton(
            onPressed: _working ? null : () => _run(() => context.read<AppState>().receivePurchase(p.id)),
            child: _working
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('MARCAR COMO RECIBIDA'),
          )
        else
          const Text('✅ Mercancía recibida en bodega', style: TextStyle(color: AppColors.asphalt, fontSize: 12.5)),
      ],
    );
  }
}