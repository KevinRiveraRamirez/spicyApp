import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/metrics.dart';
import '../../state/app_state.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/item_row.dart';
import 'widgets/expense_form_sheet.dart';
import 'widgets/income_expense_chart.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => FinanceScreenState();
}

class FinanceScreenState extends State<FinanceScreen> {
  void openNewExpenseSheet() {
    AppBottomSheet.show(context, title: 'Nuevo gasto', child: const ExpenseFormSheet());
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final rev = Metrics.sumSales(Metrics.salesInLastDays(app.sales, 30));
    final exp = Metrics.sumExpenses(Metrics.expensesInLastDays(app.expenses, 30));
    final purch = Metrics.sumPurchases(app.purchases, 30);
    final profit = rev - exp - purch;
    final list = app.expenses;

    return RefreshIndicator(
      onRefresh: app.loadAll,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
        children: [
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _MiniKpi(label: 'Ingresos · 30d', value: Formatters.money(rev), color: AppColors.success),
                _MiniKpi(label: 'Gastos · 30d', value: Formatters.money(exp + purch), color: AppColors.spicyRed),
                _MiniKpi(label: 'Utilidad neta', value: Formatters.money(profit)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ingresos vs. gastos', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                IncomeExpenseChart(sales: app.sales, expenses: app.expenses, purchases: app.purchases),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Gastos recientes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          if (list.isEmpty)
            const EmptyState(emoji: '💸', title: 'Sin gastos registrados')
          else
            ...list.map((e) => ItemRow(
                  leading: ItemThumb(emoji: '💳', background: AppColors.spicyRed.withOpacity(.1)),
                  title: e.category,
                  subtitle: '${e.description ?? ''}${e.description != null ? ' · ' : ''}${Formatters.shortDate(e.expenseDate)}',
                  trailing: Text('-${Formatters.money(e.amount)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.spicyRed)),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('¿Eliminar gasto?'),
                        content: Text('${e.category} · ${Formatters.money(e.amount)}'),
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
                      await context.read<AppState>().deleteExpense(e.id);
                    }
                  },
                )),
        ],
      ),
    );
  }
}

class _MiniKpi extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _MiniKpi({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18, color: color)),
        ],
      ),
    );
  }
}
