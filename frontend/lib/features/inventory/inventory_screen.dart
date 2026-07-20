import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/product.dart';
import '../../state/app_state.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/item_row.dart';
import 'widgets/product_form_sheet.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => InventoryScreenState();
}

class InventoryScreenState extends State<InventoryScreen> {
  String _query = '';
  String _category = 'Todos';

  void openNewProductSheet() {
    AppBottomSheet.show(context, title: 'Nueva pieza', child: const ProductFormSheet());
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final categories = ['Todos', ...{for (final p in app.products) p.category}];
    var list = app.products.where((p) => _category == 'Todos' || p.category == _category).toList();
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((p) => p.name.toLowerCase().contains(q) || p.sku.toLowerCase().contains(q)).toList();
    }

    return RefreshIndicator(
      onRefresh: app.loadAll,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar pieza o SKU...',
              prefixIcon: Icon(Icons.search, size: 20),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: categories.map((c) {
                final active = _category == c;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? Colors.white : null)),
                    selected: active,
                    selectedColor: AppColors.carbon,
                    onSelected: (_) => setState(() => _category = c),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          if (list.isEmpty)
            const EmptyState(emoji: '📦', title: 'Sin piezas todavía', subtitle: 'Agrega la primera con el botón +')
          else
            ...list.map((p) => ItemRow(
                  leading: ItemThumb(emoji: p.emoji),
                  title: p.name,
                  subtitle: '${p.category} · SKU ${p.sku}',
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(Formatters.money(p.price), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                      const SizedBox(height: 3),
                      _stockChip(p),
                    ],
                  ),
                  onTap: () => AppBottomSheet.show(context, title: 'Editar pieza', child: ProductFormSheet(product: p)),
                )),
        ],
      ),
    );
  }

  Widget _stockChip(Product p) {
    switch (p.status) {
      case StockStatus.out:
        return const StatusChip(label: 'Agotado', color: Colors.white, background: AppColors.carbon);
      case StockStatus.low:
        return StatusChip(label: '${p.stock} ${p.unit} · Bajo', color: AppColors.spicyRed, background: AppColors.spicyRed.withOpacity(.1));
      case StockStatus.ok:
        return StatusChip(label: '${p.stock} ${p.unit} · OK', color: AppColors.success, background: AppColors.success.withOpacity(.12));
    }
  }
}
