import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/purchase.dart';
import '../../../state/app_state.dart';
import '../../../widgets/spicy_buttons.dart';
import '../../../widgets/status_chip.dart';

class PurchaseDetailSheet extends StatefulWidget {
  final Purchase purchase;
  const PurchaseDetailSheet({super.key, required this.purchase});

  @override
  State<PurchaseDetailSheet> createState() => _PurchaseDetailSheetState();
}

class _PurchaseDetailSheetState extends State<PurchaseDetailSheet> {
  bool _working = false;

  Color _statusColor(BuildContext context, PurchaseStatus s) {
    final c = context.colors;
    return switch (s) {
      PurchaseStatus.pedido => c.textSecondary,
      PurchaseStatus.enTransito => c.info,
      PurchaseStatus.recibida => c.success,
    };
  }

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
    final c = context.colors;
    final color = _statusColor(context, p.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text('${p.supplierName} · ${Formatters.shortDate(p.orderedAt)}',
                  style: AppTypography.label.copyWith(color: c.textSecondary)),
            ),
            StatusChip(label: p.status.label, color: color),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...p.items.map((it) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(child: Text('${it.qty}× ${it.productName}', style: AppTypography.body.copyWith(color: c.textPrimary))),
                  if (p.isUsd)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(Formatters.usd(it.subtotalUsd), style: AppTypography.bodyMedium.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
                        Text(Formatters.money(it.subtotal), style: AppTypography.label.copyWith(color: c.textSecondary)),
                      ],
                    )
                  else
                    Text(Formatters.money(it.subtotal), style: AppTypography.bodyMedium.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
                ],
              ),
            )),
        const Divider(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total', style: AppTypography.body.copyWith(color: c.textSecondary)),
            if (p.isUsd)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Formatters.usd(p.totalUsd), style: AppTypography.metric.copyWith(color: c.textPrimary)),
                  Text('${Formatters.money(p.total)} · tipo de cambio ₡${p.exchangeRate.toStringAsFixed(2)}',
                      style: AppTypography.label.copyWith(color: c.textSecondary)),
                ],
              )
            else
              Text(Formatters.money(p.total), style: AppTypography.metric.copyWith(color: c.textPrimary)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (p.status == PurchaseStatus.pedido)
          PrimaryButton(
            label: 'Marcar en tránsito',
            icon: Icons.flight_takeoff_outlined,
            loading: _working,
            onPressed: () => _run(() => context.read<AppState>().markPurchaseInTransit(p.id)),
          )
        else if (p.status == PurchaseStatus.enTransito)
          PrimaryButton(
            label: 'Marcar como recibida',
            icon: Icons.inventory_2_outlined,
            loading: _working,
            onPressed: () => _run(() => context.read<AppState>().receivePurchase(p.id)),
          )
        else
          Row(
            children: [
              Icon(Icons.check_circle_outline, size: 18, color: c.success),
              const SizedBox(width: AppSpacing.sm),
              Text('Mercancía recibida en bodega', style: AppTypography.body.copyWith(color: c.textSecondary)),
            ],
          ),
      ],
    );
  }
}
