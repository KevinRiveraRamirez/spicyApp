import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/metrics.dart';
import '../../models/purchase.dart';
import '../../models/supplier.dart';
import '../../state/app_state.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/brand_card.dart';
import '../../widgets/brand_screen.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/item_row.dart';
import '../dashboard/widgets/kpi_card.dart';
import 'widgets/purchase_detail_sheet.dart';
import 'widgets/purchase_form_sheet.dart';
import 'widgets/supplier_form_sheet.dart';

/// Compras: mismo tratamiento de marca que Dashboard/Inventario/Ventas
/// (fondo rojo de borde a borde vía [BrandScreen]). Pensado para el
/// flujo real del negocio — mayoría proveedores de China, con un
/// tránsito de varios días/semanas antes de llegar a CR — por eso el
/// estado de cada orden tiene 3 pasos en vez de solo pendiente/recibida.
class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => PurchasesScreenState();
}

class PurchasesScreenState extends State<PurchasesScreen> {
  void openNewPurchaseSheet() {
    AppBottomSheet.show(context, title: 'Nueva orden de compra', child: const PurchaseFormSheet());
  }

  Color _statusColor(PurchaseStatus s) => switch (s) {
        PurchaseStatus.pedido => AppColors.asphalt,
        PurchaseStatus.enTransito => AppColors.info,
        PurchaseStatus.recibida => AppColors.success,
      };

  Future<void> _openLink(String raw) async {
    final hasScheme = raw.startsWith('http://') || raw.startsWith('https://');
    final uri = Uri.tryParse(hasScheme ? raw : 'https://$raw');
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace')),
        );
      }
    }
  }

  Future<void> _confirmDeleteSupplier(Supplier s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar proveedor?'),
        content: Text('${s.name} — las órdenes de compra ya hechas se conservan.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: AppColors.spicyRed)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AppState>().deleteSupplier(s.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final list = app.purchases;

    final pedidos = list.where((p) => p.status == PurchaseStatus.pedido).length;
    final enTransito = list.where((p) => p.status == PurchaseStatus.enTransito).length;
    final invertido30 = Metrics.sumPurchases(list, 30);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 700;

    final kpiData = [
      (label: 'Pedidos', value: '$pedidos'),
      (label: 'En tránsito', value: '$enTransito'),
      (label: 'Invertido (30d)', value: Formatters.money(invertido30)),
    ];

    final Widget kpiRow = isWide
        ? Row(
            children: [
              for (int i = 0; i < kpiData.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(
                  child: KpiCard(
                    label: kpiData[i].label,
                    value: kpiData[i].value,
                    width: null,
                    margin: EdgeInsets.zero,
                  ),
                ),
              ],
            ],
          )
        : SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final k in kpiData) KpiCard(label: k.label, value: k.value),
              ],
            ),
          );

    return BrandScreen(
      onRefresh: app.loadAll,
      // Igual que Inventario/Ventas: sin centrado vertical (solo el
      // Dashboard lo usa).
      centerWhenShort: false,
      children: [
        kpiRow,
        const SizedBox(height: 18),
        const Text('Órdenes de compra',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        if (list.isEmpty)
          const BrandCard(
            child: EmptyState(emoji: '🚚', title: 'Sin órdenes registradas', subtitle: 'Toca + para pedir a tu proveedor'),
          )
        else
          ...list.map((p) {
            final color = _statusColor(p.status);
            return ItemRow(
              leading: const ItemThumb(emoji: '🚚'),
              title: p.supplierName,
              subtitle: '${Formatters.shortDate(p.orderedAt)} · ${p.items.length} producto(s)',
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Formatters.money(p.total), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  const SizedBox(height: 3),
                  StatusChip(label: p.status.label, color: color, background: color.withOpacity(.12)),
                ],
              ),
              onTap: () => AppBottomSheet.show(context, title: 'Orden de compra', child: PurchaseDetailSheet(purchase: p)),
            );
          }),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Proveedores',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
            TextButton(
              onPressed: () => AppBottomSheet.show(context, title: 'Nuevo proveedor', child: const SupplierFormSheet()),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('+ Agregar'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (app.suppliers.isEmpty)
          const BrandCard(
            child: EmptyState(emoji: '🏭', title: 'Sin proveedores', subtitle: 'Agrega tu primer proveedor de China (o local)'),
          )
        else
          ...app.suppliers.map((s) {
            final hasLink = s.link != null && s.link!.trim().isNotEmpty;
            return ItemRow(
              leading: const ItemThumb(emoji: '🏭'),
              title: s.name,
              subtitle: [s.contact, s.phone].where((e) => e != null && e.isNotEmpty).join(' · '),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasLink)
                    IconButton(
                      tooltip: 'Abrir enlace',
                      onPressed: () => _openLink(s.link!.trim()),
                      icon: const Icon(Icons.link, size: 20, color: AppColors.info),
                    ),
                  IconButton(
                    tooltip: 'Eliminar proveedor',
                    onPressed: () => _confirmDeleteSupplier(s),
                    icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.spicyRed),
                  ),
                ],
              ),
              onTap: hasLink ? () => _openLink(s.link!.trim()) : null,
            );
          }),
      ],
    );
  }
}