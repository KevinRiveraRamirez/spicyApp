import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/metrics.dart';
import '../../models/purchase.dart';
import '../../state/app_state.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/brand_card.dart';
import '../../widgets/brand_screen.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/item_row.dart';
import '../dashboard/widgets/kpi_card.dart';
import 'widgets/expense_form_sheet.dart';
import 'widgets/income_expense_chart.dart';

/// Un movimiento en el estado de cuenta: puede venir de una venta, una
/// compra, o un gasto manual ("otros gastos"). Se arman los 3 al vuelo
/// desde los datos ya cargados (no hay tabla propia), así que siempre
/// están al día automáticamente con lo que pasa en Ventas/Compras.
class _Movement {
  final DateTime date;
  final String category;
  final String subtitle;
  final double amount; // positivo = ingreso (venta), negativo = gasto
  final String emoji;
  final Color color;
  final VoidCallback? onTap;

  const _Movement({
    required this.date,
    required this.category,
    required this.subtitle,
    required this.amount,
    required this.emoji,
    required this.color,
    this.onTap,
  });
}

/// Finanzas: mismo tratamiento de marca que Dashboard/Inventario/Ventas/
/// Compras (fondo rojo de borde a borde vía [BrandScreen]). El
/// historial de movimientos combina Compras y Ventas automáticamente
/// (se actualizan solas, sin registrarlas dos veces) más los "otros
/// gastos" que se agregan a mano desde acá (renta, transporte, etc.).
class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => FinanceScreenState();
}

class FinanceScreenState extends State<FinanceScreen> {
  void openNewExpenseSheet() {
    AppBottomSheet.show(context, title: 'Nuevo gasto', child: const ExpenseFormSheet());
  }

  Future<void> _confirmDeleteExpense(BuildContext context, String id, String label) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar gasto?'),
        content: Text(label),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: AppColors.spicyRed)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AppState>().deleteExpense(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final rev = Metrics.sumSales(Metrics.salesInLastDays(app.sales, 30));
    final exp = Metrics.sumExpenses(Metrics.expensesInLastDays(app.expenses, 30));
    final purch = Metrics.sumPurchases(app.purchases, 30);
    final profit = rev - exp - purch;

    final movements = <_Movement>[
      for (final s in app.sales)
        _Movement(
          date: s.soldAt,
          category: 'Venta',
          subtitle: '${Formatters.shortDateTime(s.soldAt)} · ${s.items.length} artículo(s) · ${s.paymentMethod}',
          amount: s.total,
          emoji: '🧾',
          color: AppColors.success,
        ),
      for (final p in app.purchases)
        _Movement(
          date: p.orderedAt,
          category: 'Compra · ${p.supplierName}',
          subtitle: '${Formatters.shortDate(p.orderedAt)} · ${p.items.length} producto(s) · ${p.status.label}',
          amount: -p.total,
          emoji: '🚚',
          color: AppColors.spicyRed,
        ),
      for (final e in app.expenses)
        _Movement(
          date: e.expenseDate,
          category: e.category,
          subtitle: '${Formatters.shortDate(e.expenseDate)}${e.description != null ? ' · ${e.description}' : ''}',
          amount: -e.amount,
          emoji: '💳',
          color: AppColors.spicyRed,
          onTap: () => _confirmDeleteExpense(context, e.id, '${e.category} · ${Formatters.money(e.amount)}'),
        ),
    ]..sort((a, b) => b.date.compareTo(a.date));

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 700;

    final kpiData = [
      (label: 'Ingresos · 30d', value: Formatters.money(rev), color: AppColors.success),
      (label: 'Gastos · 30d', value: Formatters.money(exp + purch), color: AppColors.spicyRed),
      (label: 'Utilidad neta', value: Formatters.money(profit), color: profit >= 0 ? AppColors.success : AppColors.spicyRed),
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
                    valueColor: kpiData[i].color,
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
                for (final k in kpiData) KpiCard(label: k.label, value: k.value, valueColor: k.color),
              ],
            ),
          );

    return BrandScreen(
      onRefresh: app.loadAll,
      // Igual que Inventario/Ventas/Compras: sin centrado vertical
      // (solo el Dashboard lo usa).
      centerWhenShort: false,
      children: [
        kpiRow,
        const SizedBox(height: 18),
        BrandCard(
          title: 'Ingresos vs. gastos',
          child: IncomeExpenseChart(sales: app.sales, expenses: app.expenses, purchases: app.purchases),
        ),
        const SizedBox(height: 18),
        const Text('Movimientos recientes',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Ventas y compras se registran solas · toca + para agregar otros gastos',
            style: TextStyle(color: Colors.white70, fontSize: 11.5)),
        const SizedBox(height: 10),
        if (movements.isEmpty)
          const BrandCard(
            child: EmptyState(emoji: '💸', title: 'Sin movimientos todavía', subtitle: 'Registra una venta, compra, o toca + para un gasto'),
          )
        else
          ...movements.map((m) => ItemRow(
                leading: ItemThumb(emoji: m.emoji, background: m.color.withOpacity(.1)),
                title: m.category,
                subtitle: m.subtitle,
                trailing: Text(
                  '${m.amount >= 0 ? '+' : '-'}${Formatters.money(m.amount.abs())}',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: m.color),
                ),
                onTap: m.onTap,
              )),
      ],
    );
  }
}