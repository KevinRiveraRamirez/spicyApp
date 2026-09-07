import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/metrics.dart';
import '../../models/purchase.dart';
import '../../models/supplier.dart';
import '../../state/app_state.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/brand_screen.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/item_row.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/section_header.dart';
import 'widgets/purchase_detail_sheet.dart';
import 'widgets/purchase_form_sheet.dart';
import 'widgets/supplier_form_sheet.dart';

const _kOriginFlags = {'China': '🇨🇳', 'Estados Unidos': '🇺🇸', 'Costa Rica': '🇨🇷'};

/// Compras: refleja el flujo real del negocio (Pedido → En tránsito →
/// Recibida), con resumen de estado arriba y "Órdenes" / "Proveedores"
/// como secciones separadas.
class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => PurchasesScreenState();
}

class PurchasesScreenState extends State<PurchasesScreen> {
  void openNewPurchaseSheet() {
    SpicyBottomSheet.show(context, title: 'Nueva orden de compra', child: const PurchaseFormSheet());
  }

  Color _statusColor(BuildContext context, PurchaseStatus s) {
    final c = context.colors;
    return switch (s) {
      PurchaseStatus.pedido => c.textSecondary,
      PurchaseStatus.enTransito => c.info,
      PurchaseStatus.recibida => c.success,
    };
  }

  Future<void> _openLink(String raw) async {
    final hasScheme = raw.startsWith('http://') || raw.startsWith('https://');
    final uri = Uri.tryParse(hasScheme ? raw : 'https://$raw');
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir el enlace')));
      }
    }
  }

  Future<void> _confirmDeleteSupplier(Supplier s) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: '¿Eliminar proveedor?',
      message: '${s.name} — las órdenes de compra ya hechas se conservan.',
    );
    if (confirmed && mounted) {
      await context.read<AppState>().deleteSupplier(s.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final c = context.colors;
    final list = app.purchases;

    final pedidos = list.where((p) => p.status == PurchaseStatus.pedido).length;
    final enTransito = list.where((p) => p.status == PurchaseStatus.enTransito).length;
    final porRecibir = pedidos + enTransito;
    final invertido30 = Metrics.sumPurchases(list, 30);

    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AppSizes.breakpointTablet;

    final metrics = [
      MetricCard(label: 'Pedidos', value: '$pedidos', icon: Icons.receipt_outlined, width: isWide ? null : 140),
      MetricCard(label: 'En tránsito', value: '$enTransito', icon: Icons.flight_takeoff_outlined, width: isWide ? null : 140),
      MetricCard(label: 'Por recibir', value: '$porRecibir', icon: Icons.pending_actions_outlined, width: isWide ? null : 140),
      MetricCard(label: 'Invertido (30d)', value: Formatters.money(invertido30), icon: Icons.payments_outlined, width: isWide ? null : 160),
    ];

    final metricsRow = isWide
        ? Row(children: [for (int i = 0; i < metrics.length; i++) ...[if (i > 0) const SizedBox(width: AppSpacing.md), Expanded(child: metrics[i])]])
        : SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: metrics.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (_, i) => metrics[i],
            ),
          );

    Widget ordersSection;
    if (list.isEmpty) {
      ordersSection = const EmptyState(
        icon: Icons.local_shipping_outlined,
        title: 'Sin órdenes registradas',
        subtitle: 'Toca "Nueva compra" para pedir a tu proveedor',
      );
    } else {
      ordersSection = Column(
        children: list.map((p) {
          final color = _statusColor(context, p.status);
          final flag = _kOriginFlags[app.suppliers.where((s) => s.name == p.supplierName).map((s) => s.origin).firstOrNull ?? ''] ?? '';
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: InkWell(
              onTap: () => SpicyBottomSheet.show(context, title: 'Orden de compra', child: PurchaseDetailSheet(purchase: p)),
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: c.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$flag ${p.supplierName}'.trim(),
                            style: AppTypography.bodyMedium.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (p.isUsd)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(Formatters.usd(p.totalUsd), style: AppTypography.bodyMedium.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
                              Text(Formatters.money(p.total), style: AppTypography.label.copyWith(color: c.textSecondary)),
                            ],
                          )
                        else
                          Text(Formatters.money(p.total), style: AppTypography.bodyMedium.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${Formatters.shortDate(p.orderedAt)} · ${p.items.length} producto(s)${p.isUsd ? ' · tipo de cambio ₡${p.exchangeRate.toStringAsFixed(2)}' : ''}',
                      style: AppTypography.label.copyWith(color: c.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _PurchaseProgress(status: p.status, color: color),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    Widget suppliersSection;
    if (app.suppliers.isEmpty) {
      suppliersSection = const EmptyState(
        icon: Icons.factory_outlined,
        title: 'Sin proveedores',
        subtitle: 'Agrega tu primer proveedor de China, EE. UU. o Costa Rica',
      );
    } else {
      suppliersSection = Column(
        children: app.suppliers.map((s) {
          final hasLink = s.link != null && s.link!.trim().isNotEmpty;
          final flag = _kOriginFlags[s.origin] ?? '';
          return ItemRow(
            leading: ItemThumb(icon: Icons.factory_outlined, foreground: c.brandPrimary, background: c.brandPrimary.withOpacity(.1)),
            title: s.name,
            subtitle: '$flag ${s.origin} · ${s.isForeign ? 'USD' : 'CRC'}'.trim(),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasLink)
                  IconButton(
                    tooltip: 'Abrir enlace',
                    onPressed: () => _openLink(s.link!.trim()),
                    icon: Icon(Icons.link, size: 20, color: c.info),
                  ),
                IconButton(
                  tooltip: 'Eliminar proveedor',
                  onPressed: () => _confirmDeleteSupplier(s),
                  icon: Icon(Icons.delete_outline, size: 20, color: c.danger),
                ),
              ],
            ),
            onTap: hasLink ? () => _openLink(s.link!.trim()) : null,
          );
        }).toList(),
      );
    }

    return SpicyScreen(
      onRefresh: app.loadAll,
      children: [
        metricsRow,
        const SizedBox(height: AppSpacing.lg),
        const SectionHeader(title: 'Órdenes de compra'),
        ordersSection,
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(
          title: 'Proveedores',
          action: TextButton.icon(
            onPressed: () => SpicyBottomSheet.show(context, title: 'Nuevo proveedor', child: const SupplierFormSheet()),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Agregar'),
          ),
        ),
        suppliersSection,
      ],
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

/// Línea de progreso Pedido → En tránsito → Recibida.
class _PurchaseProgress extends StatelessWidget {
  final PurchaseStatus status;
  final Color color;
  const _PurchaseProgress({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final steps = PurchaseStatus.values;
    final activeIndex = steps.indexOf(status);

    final dotsRow = Row(
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          if (i > 0)
            Expanded(child: Container(height: 2, color: i <= activeIndex ? color : c.border)),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: i <= activeIndex ? color : c.border),
          ),
        ],
      ],
    );

    final labelsRow = Row(
      children: steps
          .map((s) => Expanded(
                child: Text(
                  s.label,
                  style: AppTypography.label.copyWith(
                    fontSize: 9.5,
                    color: steps.indexOf(s) <= activeIndex ? color : c.textSecondary,
                    fontWeight: s == status ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ))
          .toList(),
    );

    return Semantics(
      label: 'Estado de la orden: ${status.label}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [dotsRow, const SizedBox(height: 4), labelsRow],
      ),
    );
  }
}
