import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/metrics.dart';
import '../../models/purchase.dart';
import '../../state/app_state.dart';
import '../../widgets/action_card.dart';
import '../../widgets/brand_card.dart';
import '../../widgets/brand_screen.dart';
import '../../widgets/metric_card.dart';
import '../inventory/widgets/product_form_sheet.dart' show kProductCategories;
import 'widgets/sales_trend_chart.dart';

/// Inicio: saludo contextual con fecha, 4 indicadores clave, accesos
/// rápidos a las acciones más frecuentes, tendencia de ventas y
/// alertas de inventario accionables. En móvil el orden prioriza
/// frecuencia de uso (acciones primero); en tablet/escritorio se
/// aprovecha el ancho extra con KPIs en fila fija y dos columnas.
class DashboardScreen extends StatelessWidget {
  final void Function(int tabIndex) onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final c = context.colors;
    final today = Metrics.salesInLastDays(app.sales, 1);
    final profit30 = Metrics.netProfit(sales: app.sales, expenses: app.expenses, purchases: app.purchases, days: 30);
    final lowStock = Metrics.lowStock(app.products);
    final emptyCategories = Metrics.categoriesWithNoStock(app.products, kProductCategories);
    final totalAlerts = lowStock.length + emptyCategories.length;
    final enTransito = app.purchases.where((p) => p.status == PurchaseStatus.enTransito).length;
    final trend = Metrics.dailyTrend(app.sales, days: 14);
    final top = Metrics.topProducts(app.sales, days: 30);

    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AppSizes.breakpointTablet;

    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Buenos días' : (hour < 19 ? 'Buenas tardes' : 'Buenas noches');
    final dateLabel = Formatters.longDate(DateTime.now());

    final header = Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting, style: AppTypography.display.copyWith(color: c.textPrimary, fontSize: isWide ? 28 : 24)),
          const SizedBox(height: 2),
          Text(dateLabel, style: AppTypography.body.copyWith(color: c.textSecondary)),
          const SizedBox(height: 2),
          Text('Aquí tienes el resumen de tu negocio', style: AppTypography.label.copyWith(color: c.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );

    final actions = Row(
      children: [
        Expanded(
          child: ActionCard(
            label: 'Nueva venta',
            icon: Icons.point_of_sale_rounded,
            emphasized: true,
            onTap: () => onNavigate(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ActionCard(
            label: 'Agregar producto',
            icon: Icons.add_box_outlined,
            onTap: () => onNavigate(1),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ActionCard(
            label: 'Nueva compra',
            icon: Icons.local_shipping_outlined,
            onTap: () => onNavigate(3),
          ),
        ),
      ],
    );

    final metrics = [
      MetricCard(
        label: 'Ventas de hoy',
        value: Formatters.money(Metrics.sumSales(today)),
        delta: '${today.length} tickets',
        icon: Icons.today_outlined,
        width: isWide ? null : 168,
      ),
      MetricCard(
        label: 'Utilidad (30d)',
        value: Formatters.money(profit30),
        delta: profit30 >= 0 ? 'Positiva' : 'Negativa',
        deltaPositive: profit30 >= 0,
        icon: Icons.trending_up_outlined,
        valueColor: profit30 >= 0 ? c.success : c.danger,
        width: isWide ? null : 168,
      ),
      MetricCard(
        label: 'Inventario en alerta',
        value: '$totalAlerts',
        delta: totalAlerts == 0 ? 'Todo en orden' : 'Revisar ahora',
        deltaPositive: totalAlerts == 0,
        icon: Icons.warning_amber_rounded,
        onTap: () => onNavigate(1),
        width: isWide ? null : 168,
      ),
      MetricCard(
        label: 'Compras en tránsito',
        value: '$enTransito',
        delta: enTransito == 0 ? 'Nada en camino' : 'En camino',
        deltaPositive: true,
        icon: Icons.local_shipping_outlined,
        onTap: () => onNavigate(3),
        width: isWide ? null : 168,
      ),
    ];

    final metricsRow = isWide
        ? Row(
            children: [
              for (int i = 0; i < metrics.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.md),
                Expanded(child: metrics[i]),
              ],
            ],
          )
        : SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: metrics.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (_, i) => metrics[i],
            ),
          );

    final alertRows = <Widget>[
      ...emptyCategories.map((cat) => _AlertRow(
            icon: Icons.category_outlined,
            title: cat,
            subtitle: 'Sin piezas con existencias en esta categoría',
            badge: 'Sin stock',
            onTap: () => onNavigate(1),
          )),
      ...lowStock.map((p) => _AlertRow(
            icon: Icons.inventory_2_outlined,
            title: p.name,
            subtitle: '${p.category} · SKU ${p.sku}',
            badge: 'Agotado',
            onTap: () => onNavigate(1),
          )),
    ].take(4).toList();

    final alertsCard = ContentCard(
      title: 'Alertas de inventario',
      action: TextButton(onPressed: () => onNavigate(1), child: const Text('Ver todo')),
      child: alertRows.isEmpty
          ? Row(
              children: [
                Icon(Icons.check_circle_outline, size: 18, color: c.success),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text('Todo el stock en niveles saludables', style: AppTypography.body.copyWith(color: c.textSecondary))),
              ],
            )
          : Column(children: alertRows),
    );

    final chartCard = ContentCard(
      title: 'Tendencia de ventas · 14 días',
      child: trend.every((v) => v == 0)
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Text('Todavía no hay ventas en este periodo', style: AppTypography.body.copyWith(color: c.textSecondary)),
              ),
            )
          : SalesTrendChart(values: trend),
    );

    final topCard = ContentCard(
      title: 'Top piezas · 30 días',
      child: top.isEmpty
          ? Text('Aún no hay ventas suficientes.', style: AppTypography.body.copyWith(color: c.textSecondary))
          : Column(
              children: top.map((e) {
                final max = top.first.value;
                final ratio = max == 0 ? 0.0 : e.value / max;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(e.key, style: AppTypography.body.copyWith(color: c.textPrimary), overflow: TextOverflow.ellipsis)),
                          Text('${e.value}', style: AppTypography.bodyMedium.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 7,
                          backgroundColor: c.surfaceAlt,
                          valueColor: AlwaysStoppedAnimation(c.brandPrimary),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );

    final lowerSection = isWide
        ? IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 3, child: chartCard),
                const SizedBox(width: AppSpacing.md),
                Expanded(flex: 2, child: alertsCard),
              ],
            ),
          )
        : Column(children: [alertsCard, const SizedBox(height: AppSpacing.md), chartCard]);

    final children = isWide
        ? [
            header,
            metricsRow,
            const SizedBox(height: AppSpacing.lg),
            actions,
            const SizedBox(height: AppSpacing.xl),
            lowerSection,
            const SizedBox(height: AppSpacing.md),
            topCard,
          ]
        : [
            header,
            actions,
            const SizedBox(height: AppSpacing.lg),
            metricsRow,
            const SizedBox(height: AppSpacing.lg),
            alertsCard,
            const SizedBox(height: AppSpacing.md),
            chartCard,
            const SizedBox(height: AppSpacing.md),
            topCard,
          ];

    return SpicyScreen(onRefresh: app.loadAll, children: children);
  }
}

class _AlertRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;
  const _AlertRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: '$title, $subtitle, $badge',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.control),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: c.danger.withOpacity(.1), borderRadius: BorderRadius.circular(AppRadius.control)),
                alignment: Alignment.center,
                child: Icon(icon, color: c.danger, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.bodyMedium.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
                    Text(subtitle, style: AppTypography.label.copyWith(color: c.textSecondary, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(color: c.danger.withOpacity(.12), borderRadius: BorderRadius.circular(20)),
                child: Text(badge, style: AppTypography.label.copyWith(color: c.danger, fontSize: 11)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
