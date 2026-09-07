import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/metrics.dart';
import '../../models/purchase.dart';
import '../../state/app_state.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/brand_screen.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_chip_group.dart';
import '../../widgets/item_row.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/brand_card.dart';
import '../../widgets/section_header.dart';
import 'widgets/expense_form_sheet.dart';
import 'widgets/income_expense_chart.dart';

/// Un movimiento en el estado de cuenta: puede venir de una venta, una
/// compra, o un gasto manual ("otros gastos"). Se arman los 3 al vuelo
/// desde los datos ya cargados (no hay tabla propia), así que siempre
/// están al día automáticamente con lo que pasa en Ventas/Compras.
class _Movement {
  final DateTime date;
  final String type; // Venta | Compra | Gasto — para el filtro
  final String category;
  final String subtitle;
  final double amount; // positivo = ingreso (venta), negativo = gasto
  final IconData icon;
  final VoidCallback? onTap;

  const _Movement({
    required this.date,
    required this.type,
    required this.category,
    required this.subtitle,
    required this.amount,
    required this.icon,
    this.onTap,
  });
}

const _kTypes = ['Todos', 'Venta', 'Compra', 'Gasto'];
const _kPeriods = ['Todos', 'Hoy', '7 días', '30 días'];

/// Finanzas: resumen de ingresos/gastos/utilidad, gráfico con leyenda
/// y rango configurable, y el historial de movimientos (ventas y
/// compras automáticas + gastos manuales) con filtros por tipo y
/// periodo.
class FinanceScreen extends StatefulWidget {
  final VoidCallback? onNavigateToSales;

  const FinanceScreen({super.key, this.onNavigateToSales});

  @override
  State<FinanceScreen> createState() => FinanceScreenState();
}

class FinanceScreenState extends State<FinanceScreen> {
  String _type = 'Todos';
  String _period = 'Todos';
  int _chartWeeks = 6;

  void openNewExpenseSheet() {
    SpicyBottomSheet.show(context, title: 'Nuevo gasto', child: const ExpenseFormSheet());
  }

  Future<void> _confirmDeleteExpense(BuildContext context, String id, String label) async {
    final confirmed = await ConfirmDialog.show(context, title: '¿Eliminar gasto?', message: label);
    if (confirmed && context.mounted) {
      await context.read<AppState>().deleteExpense(id);
    }
  }

  bool _inPeriod(DateTime date) {
    if (_period == 'Todos') return true;
    final days = switch (_period) { 'Hoy' => 1, '7 días' => 7, '30 días' => 30, _ => 100000 };
    final from = DateTime.now().subtract(Duration(days: days - 1));
    final d = DateTime(date.year, date.month, date.day);
    final f = DateTime(from.year, from.month, from.day);
    return !d.isBefore(f);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final c = context.colors;
    final rev = Metrics.sumSales(Metrics.salesInLastDays(app.sales, 30));
    final exp = Metrics.sumExpenses(Metrics.expensesInLastDays(app.expenses, 30));
    final purch = Metrics.sumPurchases(app.purchases, 30);
    final profit = rev - exp - purch;

    var movements = <_Movement>[
      for (final s in app.sales)
        _Movement(
          date: s.soldAt,
          type: 'Venta',
          category: 'Venta',
          subtitle: '${Formatters.shortDateTime(s.soldAt)} · ${s.items.length} artículo(s) · ${s.paymentMethod}',
          amount: s.total,
          icon: Icons.receipt_long_outlined,
        ),
      for (final p in app.purchases)
        _Movement(
          date: p.orderedAt,
          type: 'Compra',
          category: 'Compra · ${p.supplierName}',
          subtitle:
              '${Formatters.shortDate(p.orderedAt)} · ${p.items.length} producto(s) · ${p.status.label}${p.isUsd ? ' · ${Formatters.usd(p.totalUsd)}' : ''}',
          amount: -p.total,
          icon: Icons.local_shipping_outlined,
        ),
      for (final e in app.expenses)
        _Movement(
          date: e.expenseDate,
          type: 'Gasto',
          category: e.category,
          subtitle: '${Formatters.shortDate(e.expenseDate)}${e.description != null ? ' · ${e.description}' : ''}',
          amount: -e.amount,
          icon: Icons.payments_outlined,
          onTap: () => _confirmDeleteExpense(context, e.id, '${e.category} · ${Formatters.money(e.amount)}'),
        ),
    ]..sort((a, b) => b.date.compareTo(a.date));

    if (_type != 'Todos') movements = movements.where((m) => m.type == _type).toList();
    movements = movements.where((m) => _inPeriod(m.date)).toList();

    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AppSizes.breakpointTablet;

    Widget metricCard(String label, String value, IconData icon, Color? valueColor, {double? width}) {
      return MetricCard(label: label, value: value, icon: icon, valueColor: valueColor, width: width);
    }

    // Grilla responsive: 3 columnas en tablet/escritorio; en móvil, 2
    // columnas con "Utilidad neta" a ancho completo en la 2da fila (o 1
    // columna si la pantalla es muy angosta) — nunca 3 tarjetas de ancho
    // fijo apretadas en un scroll que corta la última.
    final metricsRow = isWide
        ? Row(
            children: [
              Expanded(child: metricCard('Ingresos · 30d', Formatters.money(rev), Icons.trending_up_outlined, c.success)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: metricCard('Gastos · 30d', Formatters.money(exp + purch), Icons.trending_down_outlined, c.danger)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: metricCard('Utilidad neta', Formatters.money(profit), Icons.account_balance_wallet_outlined, profit >= 0 ? c.success : c.danger)),
            ],
          )
        : LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 340) {
                return Column(
                  children: [
                    metricCard('Ingresos · 30d', Formatters.money(rev), Icons.trending_up_outlined, c.success, width: constraints.maxWidth),
                    const SizedBox(height: AppSpacing.sm),
                    metricCard('Gastos · 30d', Formatters.money(exp + purch), Icons.trending_down_outlined, c.danger, width: constraints.maxWidth),
                    const SizedBox(height: AppSpacing.sm),
                    metricCard('Utilidad neta', Formatters.money(profit), Icons.account_balance_wallet_outlined, profit >= 0 ? c.success : c.danger,
                        width: constraints.maxWidth),
                  ],
                );
              }
              final halfWidth = (constraints.maxWidth - AppSpacing.sm) / 2;
              return Column(
                children: [
                  Row(
                    children: [
                      metricCard('Ingresos · 30d', Formatters.money(rev), Icons.trending_up_outlined, c.success, width: halfWidth),
                      const SizedBox(width: AppSpacing.sm),
                      metricCard('Gastos · 30d', Formatters.money(exp + purch), Icons.trending_down_outlined, c.danger, width: halfWidth),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  metricCard('Utilidad neta', Formatters.money(profit), Icons.account_balance_wallet_outlined, profit >= 0 ? c.success : c.danger,
                      width: constraints.maxWidth),
                ],
              );
            },
          );

    Widget movementsList;
    if (app.sales.isEmpty && app.purchases.isEmpty && app.expenses.isEmpty) {
      movementsList = EmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Sin movimientos en este periodo',
        subtitle: 'Registra una venta o un gasto y aparecerán aquí automáticamente',
        actionLabel: 'Registrar gasto',
        actionIcon: Icons.payments_outlined,
        onAction: openNewExpenseSheet,
        secondaryLabel: widget.onNavigateToSales != null ? 'Nueva venta' : null,
        secondaryIcon: Icons.point_of_sale,
        onSecondary: widget.onNavigateToSales,
      );
    } else if (movements.isEmpty) {
      movementsList = const EmptyState(icon: Icons.filter_alt_off_outlined, title: 'Sin movimientos con estos filtros');
    } else {
      movementsList = Column(
        children: movements
            .map((m) => ItemRow(
                  leading: ItemThumb(
                    icon: m.icon,
                    foreground: m.amount >= 0 ? c.success : c.danger,
                    background: (m.amount >= 0 ? c.success : c.danger).withOpacity(.1),
                  ),
                  title: m.category,
                  subtitle: m.subtitle,
                  trailing: Text(
                    '${m.amount >= 0 ? '+' : '-'}${Formatters.money(m.amount.abs())}',
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: m.amount >= 0 ? c.success : c.danger),
                  ),
                  onTap: m.onTap,
                ))
            .toList(),
      );
    }

    final hasAnyMovement = app.sales.isNotEmpty || app.purchases.isNotEmpty || app.expenses.isNotEmpty;

    return SpicyScreen(
      onRefresh: app.loadAll,
      // Espacio extra abajo solo si hay movimientos (y por lo tanto FAB
      // "Registrar gasto" visible) — vacío usa el CTA del EmptyState.
      extraPadding: hasAnyMovement ? const EdgeInsets.only(bottom: 48) : null,
      children: [
        metricsRow,
        const SizedBox(height: AppSpacing.lg),
        ContentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ChartHeader(weeks: _chartWeeks, onChanged: (v) => setState(() => _chartWeeks = v)),
              const SizedBox(height: AppSpacing.md),
              IncomeExpenseChart(sales: app.sales, expenses: app.expenses, purchases: app.purchases, weeks: _chartWeeks),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(
          title: 'Movimientos recientes',
          subtitle: 'Ventas y compras se registran solas · toca "Registrar gasto" para agregar otros gastos',
        ),
        const SizedBox(height: AppSpacing.xs),
        Text('Tipo', style: AppTypography.label.copyWith(color: c.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        FilterChipGroup(options: _kTypes, selected: _type, onSelected: (v) => setState(() => _type = v)),
        const SizedBox(height: AppSpacing.sm),
        Text('Periodo', style: AppTypography.label.copyWith(color: c.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        FilterChipGroup(options: _kPeriods, selected: _period, onSelected: (v) => setState(() => _period = v)),
        const SizedBox(height: AppSpacing.md),
        movementsList,
      ],
    );
  }
}

/// Encabezado de la tarjeta del gráfico: título + selector de semanas.
/// En angosto se apilan (título en su propia línea, selector debajo);
/// si hay suficiente ancho van en la misma fila. Así el chip nunca sale
/// de los límites de la tarjeta.
class _ChartHeader extends StatelessWidget {
  final int weeks;
  final ValueChanged<int> onChanged;
  const _ChartHeader({required this.weeks, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final title = Text('Ingresos vs. gastos', style: AppTypography.sectionTitle.copyWith(color: c.textPrimary, fontSize: 15));
        final subtitle = Text('Últimas $weeks semanas', style: AppTypography.label.copyWith(color: c.textSecondary));
        final toggle = _WeeksToggle(weeks: weeks, onChanged: onChanged);

        if (constraints.maxWidth >= 420) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [title, const SizedBox(height: 2), subtitle],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              toggle,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title,
            const SizedBox(height: 2),
            subtitle,
            const SizedBox(height: AppSpacing.sm),
            toggle,
          ],
        );
      },
    );
  }
}

/// Selector compacto de rango temporal para el gráfico — a diferencia
/// de [FilterChipGroup] (pensado para ocupar todo el ancho con
/// scroll), este va dentro del encabezado de una tarjeta, así que se
/// dimensiona a su contenido en vez de expandirse.
class _WeeksToggle extends StatelessWidget {
  final int weeks;
  final ValueChanged<int> onChanged;
  const _WeeksToggle({required this.weeks, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget option(int w) {
      final active = weeks == w;
      return InkWell(
        onTap: () => onChanged(w),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: active ? c.brandPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$w sem.',
            style: AppTypography.label.copyWith(color: active ? Colors.white : c.textSecondary, fontSize: 11),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: c.surfaceAlt, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [option(6), option(12)]),
    );
  }
}
