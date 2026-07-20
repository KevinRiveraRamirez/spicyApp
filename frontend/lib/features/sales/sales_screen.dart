import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/metrics.dart';
import '../../state/app_state.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/item_row.dart';
import 'widgets/pos_sheet.dart';
import 'widgets/sale_detail_sheet.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => SalesScreenState();
}

class SalesScreenState extends State<SalesScreen> {
  void openNewSaleSheet() {
    AppBottomSheet.show(context, title: 'Nueva venta', child: const PosSheet());
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final today = Metrics.salesInLastDays(app.sales, 1);
    final week = Metrics.salesInLastDays(app.sales, 7);
    final avg = Metrics.averageTicket(app.sales);
    final list = app.sales;

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
                _MiniKpi(label: 'Hoy', value: Formatters.money(Metrics.sumSales(today))),
                _MiniKpi(label: 'Esta semana', value: Formatters.money(Metrics.sumSales(week))),
                _MiniKpi(label: 'Ticket promedio', value: Formatters.money(avg)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text('Historial de ventas', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          if (list.isEmpty)
            const EmptyState(emoji: '🧾', title: 'Cero ventas aún', subtitle: 'Toca + y registra la primera')
          else
            ...list.map((s) => ItemRow(
                  leading: ItemThumb(emoji: '🧾', background: AppColors.success.withOpacity(.12)),
                  title: '${s.items.length} artículo(s) · ${s.paymentMethod}',
                  subtitle: Formatters.shortDate(s.soldAt),
                  trailing: Text(Formatters.money(s.total), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  onTap: () => AppBottomSheet.show(context, title: 'Detalle de venta', child: SaleDetailSheet(sale: s)),
                )),
        ],
      ),
    );
  }
}

class _MiniKpi extends StatelessWidget {
  final String label;
  final String value;
  const _MiniKpi({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
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
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18)),
        ],
      ),
    );
  }
}
