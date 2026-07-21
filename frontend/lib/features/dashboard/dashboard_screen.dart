import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/metrics.dart';
import '../../state/app_state.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/spicy_logo.dart';
import 'widgets/kpi_card.dart';
import 'widgets/sales_trend_chart.dart';

/// Dashboard: fondo con el mismo degradado rojo de lock/login (borde a
/// borde) y "cajitas" blancas de contenido. El ancho y la disposición
/// de esas cajitas se adaptan al tamaño real de pantalla:
///  - Teléfono (< 700): igual que hoy, KPIs en fila con scroll.
///  - Tablet/PC (>= 700): el contenido crece con la ventana (no se
///    queda fijo en una columna angosta), las 4 KPI se acomodan en
///    una sola fila fija, y Alertas/Top piezas van lado a lado.
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

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 700;
    // El contenido crece con la pantalla en vez de quedarse fijo:
    // teléfono usa todo el ancho disponible; tablet toma ~92%; PC se
    // limita a un máximo generoso para no perder legibilidad.
    final double contentMaxWidth = screenWidth < 700
        ? screenWidth
        : screenWidth < 1100
            ? screenWidth * 0.92
            : (screenWidth * 0.75).clamp(900, 1200).toDouble();

    final kpiData = [
      (label: 'Ventas hoy', value: Formatters.money(Metrics.sumSales(today)), delta: '${today.length} tickets', positive: true),
      (label: 'Ventas 7 días', value: Formatters.money(Metrics.sumSales(week)), delta: '${week.length} tickets', positive: true),
      (
        label: 'Utilidad (30d)',
        value: Formatters.money(profit30),
        delta: profit30 >= 0 ? 'Positiva' : 'Negativa',
        positive: profit30 >= 0,
      ),
      (
        label: 'SKUs activos',
        value: '${app.products.length}',
        delta: '${lowStock.length} en alerta',
        positive: lowStock.isEmpty,
      ),
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
                    delta: kpiData[i].delta,
                    positive: kpiData[i].positive,
                    width: null,
                    margin: EdgeInsets.zero,
                  ),
                ),
              ],
            ],
          )
        : SizedBox(
            height: 118,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final k in kpiData)
                  KpiCard(label: k.label, value: k.value, delta: k.delta, positive: k.positive),
              ],
            ),
          );

    final Widget alertsCard = _Card(
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
                            Text('${p.category} · SKU ${p.sku}',
                                style: const TextStyle(fontSize: 11.5, color: AppColors.asphalt)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.spicyRed.withOpacity(.12), borderRadius: BorderRadius.circular(20)),
                        child: const Text('Agotado',
                            style: TextStyle(color: AppColors.spicyRed, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );

    final Widget topCard = _Card(
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
    );

    final Widget lowerCards = isWide
        ? IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: alertsCard),
                const SizedBox(width: 14),
                Expanded(child: topCard),
              ],
            ),
          )
        : Column(
            children: [
              alertsCard,
              const SizedBox(height: 14),
              topCard,
            ],
          );

    return Stack(
      children: [
        // Fondo: mismo degradado rojo de lock/login, borde a borde,
        // siempre cubre el alto disponible (aunque el contenido sea
        // corto).
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.spicyRed, AppColors.spicyRedDark, Color(0xFF1A0405)],
              ),
            ),
          ),
        ),
        // Marca de agua: el wordmark bien tenue anclado abajo, para que
        // en pantallas altas (tablet/PC) el espacio sobrante se sienta
        // diseñado y no vacío.
        Positioned(
          left: 0,
          right: 0,
          bottom: -30,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.06,
              child: Center(child: SpicyLogo(width: 320)),
            ),
          ),
        ),
        ResponsiveCenter(
          maxWidth: contentMaxWidth,
          child: RefreshIndicator(
            onRefresh: app.loadAll,
            color: AppColors.spicyRed,
            // La barra superior es transparente y flota sobre este mismo
            // fondo (ver root_shell.dart): SafeArea cubre el notch/status
            // bar, y sumamos kToolbarHeight para no quedar tapados por
            // la barra.
            child: SafeArea(
              bottom: false,
              // Cuando el contenido es corto (poca data todavía), queda
              // centrado de arriba hacia abajo en vez de pegado al tope.
              // En cuanto crece más allá del alto de pantalla, se
              // comporta como una lista normal que se puede desplazar.
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const topPad = 16.0 + kToolbarHeight;
                  const bottomPad = 110.0;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, topPad, 20, bottomPad),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: (constraints.maxHeight - topPad - bottomPad).clamp(0, double.infinity),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          kpiRow,
                          const SizedBox(height: 18),
                          _QuickGrid(onNavigate: onNavigate),
                          const SizedBox(height: 18),
                          _Card(
                            title: 'Tendencia de ventas · 14 días',
                            child: SalesTrendChart(values: trend),
                          ),
                          const SizedBox(height: 14),
                          lowerCards,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickGrid extends StatelessWidget {
  final void Function(int) onNavigate;
  const _QuickGrid({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final items = [
      (icon: Icons.point_of_sale_rounded, label: 'Nueva venta', fg: AppColors.spicyRed, tab: 2),
      (icon: Icons.inventory_2_rounded, label: 'Inventario', fg: AppColors.carbon, tab: 1),
      (icon: Icons.local_shipping_rounded, label: 'Compras', fg: AppColors.spicyRed, tab: 3),
      (icon: Icons.account_balance_wallet_rounded, label: 'Finanzas', fg: AppColors.carbon, tab: 4),
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
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Icon(it.icon, color: it.fg, size: 22),
                ),
                const SizedBox(height: 7),
                Text(it.label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white), textAlign: TextAlign.center),
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.carbon)),
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