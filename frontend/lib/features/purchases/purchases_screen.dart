import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/purchase.dart';
import '../../state/app_state.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/item_row.dart';
import 'widgets/purchase_detail_sheet.dart';
import 'widgets/purchase_form_sheet.dart';
import 'widgets/supplier_form_sheet.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => PurchasesScreenState();
}

class PurchasesScreenState extends State<PurchasesScreen> {
  void openNewPurchaseSheet() {
    AppBottomSheet.show(context, title: 'Nueva orden de compra', child: const PurchaseFormSheet());
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final list = app.purchases;

    return RefreshIndicator(
      onRefresh: app.loadAll,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
        children: [
          Text('Órdenes de compra', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          if (list.isEmpty)
            const EmptyState(emoji: '🚚', title: 'Sin órdenes registradas', subtitle: 'Toca + para pedir a tu proveedor')
          else
            ...list.map((p) => ItemRow(
                  leading: const ItemThumb(emoji: '🚚'),
                  title: p.supplierName,
                  subtitle: '${Formatters.shortDate(p.orderedAt)} · ${p.items.length} producto(s)',
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(Formatters.money(p.total), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                      const SizedBox(height: 3),
                      StatusChip(
                        label: p.status == PurchaseStatus.recibida ? 'Recibida' : 'Pendiente',
                        color: p.status == PurchaseStatus.recibida ? AppColors.success : AppColors.spicyRed,
                        background: (p.status == PurchaseStatus.recibida ? AppColors.success : AppColors.spicyRed).withOpacity(.12),
                      ),
                    ],
                  ),
                  onTap: () => AppBottomSheet.show(context, title: 'Orden de compra', child: PurchaseDetailSheet(purchase: p)),
                )),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Proveedores', style: Theme.of(context).textTheme.titleMedium),
              TextButton(
                onPressed: () => AppBottomSheet.show(context, title: 'Nuevo proveedor', child: const SupplierFormSheet()),
                child: const Text('+ Agregar'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...app.suppliers.map((s) => ItemRow(
                leading: const ItemThumb(emoji: '🏭'),
                title: s.name,
                subtitle: [s.contact, s.phone].where((e) => e != null && e.isNotEmpty).join(' · '),
              )),
        ],
      ),
    );
  }
}
