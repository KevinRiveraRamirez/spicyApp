import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/metrics.dart';
import '../../state/app_state.dart';
import 'widgets/kpi_card.dart';
import 'widgets/sales_trend_chart.dart';

class DashboardScreen extends StatelessWidget {
  final void Function(int tabIndex) onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final today = Metrics.salesInLastDays(app.sales, 1);
    final week = Metrics.salesInLastDays(app.sales, 7);
    final profit30 = Metrics.netProfit(sales: app.sales, expenses: app.expenses, purchases: app.purchases, days: 30);
    final lowStock = Metrics.lowStock(app.products);
    final trend = Metrics.dailyTrend(app.sales, days: 14);
    final top = Metrics.topProducts(app.sales, days: 30);

    return RefreshIndicator(
      onRefresh: app.loadAll,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
        children: [
          SizedBox(
            height: 118,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                KpiCard(label: 'Ventas hoy', value: Formatters.money(Metrics.sumSales(today)), delta: '${today.length} tickets'),
                KpiCard(label: 'Ventas 7 días', value: Formatters.money(Metrics.sumSales(week)), delta: '${week.length} tickets'),
                KpiCard(
                  label: 'Utilidad (30d)',
                  value: Formatters.money(profit30),
                  delta: profit30 >= 0 ? 'Positiva' : 'Negativa',
                  positive: profit30 >= 0,
                ),
                KpiCard(
                  label: 'SKUs activos',
                  value: '${app.products.length}',
                  delta: '${lowStock.length} en alerta',
                  positive: lowStock.isEmpty,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _QuickGrid(onNavigate: onNavigate),
          const SizedBox(height: 18),
          _Card(
            title: 'Tendencia de ventas · 14 días',
            child: SalesTrendChart(values: trend),
          ),
          const SizedBox(height: 14),
          _Card(
            title: 'Alertas de inventario',
            action: TextButton(onPressed: () => onNavigate(1), child: const Text('Ver todo')),
            child: lowStock.isEmpty
                ? const Text('Todo el stock en niveles saludables ✅', style: TextStyle(fontSize: 12.5, color: AppColors.asphalt))
                : Column(
                    children: lowStock.take(4).map((p) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 34, height: 34,
                              decoration: BoxDecoration(color: AppColors.spicyRed.withOpacity(.1), borderRadius: BorderRadius.circular(10)),
                              alignment: Alignment.center,
                              child: const Icon(Icons.warning_amber_rounded, color: AppColors.spicyRed, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                                  Text('Quedan ${p.stock} ${p.unit} · mínimo ${p.minStock}',
                                      style: const TextStyle(fontSize: 11.5, color: AppColors.asphalt)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                              decoration: BoxDecoration(color: AppColors.spicyRed.withOpacity(.12), borderRadius: BorderRadius.circular(20)),
                              child: Text(p.stock == 0 ? 'Agotado' : 'Bajo',
                                  style: const TextStyle(color: AppColors.spicyRed, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 14),
          _Card(
            title: 'Top piezas · 30 días',
            child: top.isEmpty
                ? const Text('Aún no hay ventas suficientes.', style: TextStyle(fontSize: 12.5, color: AppColors.asphalt))
                : Column(
                    children: top.map((e) {
                      final max = top.first.value;
                      final ratio = max == 0 ? 0.0 : e.value / max;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(e.key, style: const TextStyle(fontSize: 12.5), overflow: TextOverflow.ellipsis)),
                                Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: ratio,
                                minHeight: 7,
                                backgroundColor: AppColors.lightSurfaceAlt,
                                valueColor: const AlwaysStoppedAnimation(AppColors.spicyRed),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _QuickGrid extends StatelessWidget {
  final void Function(int) onNavigate;
  const _QuickGrid({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final items = [
      (icon: Icons.point_of_sale_rounded, label: 'Nueva venta', bg: AppColors.spicyRed, fg: Colors.white, tab: 2),
      (icon: Icons.inventory_2_rounded, label: 'Inventario', bg: AppColors.carbon, fg: Colors.white, tab: 1),
      (icon: Icons.local_shipping_rounded, label: 'Compras', bg: AppColors.asphalt, fg: Colors.white, tab: 3),
      (icon: Icons.account_balance_wallet_rounded, label: 'Finanzas', bg: AppColors.bone, fg: AppColors.carbon, tab: 4),
    ];
    return Row(
      children: items.map((it) {
        return Expanded(
          child: InkWell(
            onTap: () => onNavigate(it.tab),
            child: Column(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(color: it.bg, borderRadius: BorderRadius.circular(15)),
                  alignment: Alignment.center,
                  child: Icon(it.icon, color: it.fg, size: 22),
                ),
                const SizedBox(height: 7),
                Text(it.label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.asphalt), textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;
  const _Card({required this.title, required this.child, this.action});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
