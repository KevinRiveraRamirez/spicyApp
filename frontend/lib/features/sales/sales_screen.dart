import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/metrics.dart';
import '../../models/sale.dart';
import '../../state/app_state.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/brand_screen.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_chip_group.dart';
import '../../widgets/item_row.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/section_header.dart';
import 'widgets/pos_sheet.dart';
import 'widgets/sale_detail_sheet.dart';

const _kPeriods = ['Todos', 'Hoy', '7 días', '30 días'];
const _kMethods = ['Todos', 'Efectivo', 'Sinpe', 'Transferencia'];

/// Ventas: 3 KPIs arriba, historial con filtros por periodo y método
/// de pago. La acción principal ("Nueva venta") vive en el FAB del
/// shell — este flujo es un asistente por pasos (ver [PosController]).
class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => SalesScreenState();
}

class SalesScreenState extends State<SalesScreen> {
  String _period = 'Todos';
  String _method = 'Todos';

  void openNewSaleSheet() {
    final app = context.read<AppState>();
    final controller = PosController(app);
    SpicyBottomSheet.show(
      context,
      title: 'Punto de venta',
      child: PosBody(controller: controller),
      stickyFooter: PosFooter(controller: controller),
    );
  }

  bool _inPeriod(Sale s) {
    if (_period == 'Todos') return true;
    final days = switch (_period) {
      'Hoy' => 1,
      '7 días' => 7,
      '30 días' => 30,
      _ => 100000,
    };
    return Metrics.salesInLastDays([s], days).isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final c = context.colors;
    final today = Metrics.salesInLastDays(app.sales, 1);
    final week = Metrics.salesInLastDays(app.sales, 7);
    final avg = Metrics.averageTicket(app.sales);

    var list = app.sales.where(_inPeriod).toList();
    if (_method != 'Todos') list = list.where((s) => s.paymentMethod == _method).toList();

    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AppSizes.breakpointTablet;

    // Grilla en móvil: "Hoy" y "Esta semana" en la primera fila, "Ticket
    // promedio" a ancho completo abajo — nunca una fila con scroll que
    // deja una tarjeta a medio cortar.
    final metricsRow = isWide
        ? Row(
            children: [
              Expanded(child: MetricCard(label: 'Hoy', value: Formatters.money(Metrics.sumSales(today)), icon: Icons.today_outlined)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: MetricCard(label: 'Esta semana', value: Formatters.money(Metrics.sumSales(week)), icon: Icons.calendar_view_week_outlined)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: MetricCard(label: 'Ticket promedio', value: Formatters.money(avg), icon: Icons.receipt_long_outlined)),
            ],
          )
        : LayoutBuilder(
            builder: (context, constraints) {
              final halfWidth = (constraints.maxWidth - AppSpacing.sm) / 2;
              return Column(
                children: [
                  Row(
                    children: [
                      MetricCard(label: 'Hoy', value: Formatters.money(Metrics.sumSales(today)), icon: Icons.today_outlined, width: halfWidth),
                      const SizedBox(width: AppSpacing.sm),
                      MetricCard(
                        label: 'Esta semana',
                        value: Formatters.money(Metrics.sumSales(week)),
                        icon: Icons.calendar_view_week_outlined,
                        width: halfWidth,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  MetricCard(label: 'Ticket promedio', value: Formatters.money(avg), icon: Icons.receipt_long_outlined, width: constraints.maxWidth),
                ],
              );
            },
          );

    Widget history;
    if (app.isLoading && app.sales.isEmpty) {
      history = const SizedBox.shrink();
    } else if (app.sales.isEmpty) {
      history = EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Aún no registras ventas',
        subtitle: 'Cuando vendas algo, aparecerá aquí con su detalle y método de pago',
        actionLabel: 'Registrar primera venta',
        actionIcon: Icons.point_of_sale,
        onAction: openNewSaleSheet,
      );
    } else if (list.isEmpty) {
      history = const EmptyState(icon: Icons.filter_alt_off_outlined, title: 'Sin ventas con estos filtros');
    } else {
      history = Column(
        children: list
            .map((s) => ItemRow(
                  leading: ItemThumb(icon: Icons.receipt_long_outlined, foreground: c.success, background: c.success.withOpacity(.1)),
                  title: '${s.items.length} artículo(s) · ${s.paymentMethod}',
                  subtitle: Formatters.shortDateTime(s.soldAt),
                  trailing: Text(Formatters.money(s.total), style: AppTypography.bodyMedium.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
                  onTap: () => SaleDetailSheet.open(context, s),
                ))
            .toList(),
      );
    }

    return SpicyScreen(
      onRefresh: app.loadAll,
      // Deja espacio de sobra abajo para que el FAB "Nueva venta" (móvil
      // y tablet) nunca tape el último elemento del historial.
      extraPadding: const EdgeInsets.only(bottom: 48),
      children: [
        metricsRow,
        const SizedBox(height: AppSpacing.md),
        const SectionHeader(title: 'Historial de ventas'),
        const SizedBox(height: AppSpacing.xs),
        Text('Periodo', style: AppTypography.label.copyWith(color: c.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        FilterChipGroup(options: _kPeriods, selected: _period, onSelected: (v) => setState(() => _period = v)),
        const SizedBox(height: AppSpacing.sm),
        Text('Método de pago', style: AppTypography.label.copyWith(color: c.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        FilterChipGroup(options: _kMethods, selected: _method, onSelected: (v) => setState(() => _method = v)),
        const SizedBox(height: AppSpacing.md),
        history,
      ],
    );
  }
}
