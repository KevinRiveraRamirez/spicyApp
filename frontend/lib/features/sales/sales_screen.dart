import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/metrics.dart';
import '../../state/app_state.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/brand_card.dart';
import '../../widgets/brand_screen.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/item_row.dart';
import '../dashboard/widgets/kpi_card.dart';
import 'widgets/pos_sheet.dart';
import 'widgets/sale_detail_sheet.dart';

/// Ventas: mismo tratamiento de marca que Dashboard/Inventario (fondo
/// rojo de borde a borde vía [BrandScreen]). Los 3 KPI van arriba
/// (fila fija en tablet/PC, scroll horizontal en teléfono, igual que
/// el Dashboard); cada venta es su propia cajita blanca apilada.
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

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 700;

    final kpiData = [
      (label: 'Hoy', value: Formatters.money(Metrics.sumSales(today))),
      (label: 'Esta semana', value: Formatters.money(Metrics.sumSales(week))),
      (label: 'Ticket promedio', value: Formatters.money(avg)),
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
      // Igual que Inventario: sin centrado vertical (solo el Dashboard
      // lo usa). Aquí la lista queda fija arriba.
      centerWhenShort: false,
      children: [
        kpiRow,
        const SizedBox(height: 18),
        const Text('Historial de ventas',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        if (list.isEmpty)
          const BrandCard(
            child: EmptyState(emoji: '🧾', title: 'Cero ventas aún', subtitle: 'Toca + y registra la primera'),
          )
        else
          ...list.map((s) => ItemRow(
                leading: ItemThumb(emoji: '🧾', background: AppColors.success.withOpacity(.12)),
                title: '${s.items.length} artículo(s) · ${s.paymentMethod}',
                subtitle: Formatters.shortDateTime(s.soldAt),
                trailing: Text(Formatters.money(s.total), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                onTap: () => AppBottomSheet.show(context, title: 'Detalle de venta', child: SaleDetailSheet(sale: s)),
              )),
      ],
    );
  }
}