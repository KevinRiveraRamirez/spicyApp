import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/product.dart';
import '../../state/app_state.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/brand_card.dart';
import '../../widgets/brand_screen.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/item_row.dart';
import 'widgets/product_form_sheet.dart';

/// Inventario: mismo tratamiento de marca que el Dashboard (fondo rojo
/// de borde a borde vía [BrandScreen]). El buscador y los filtros de
/// categoría van en una cajita blanca arriba; cada pieza es su propia
/// cajita blanca (ya lo resuelve [ItemRow]) apilada sobre el rojo.
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
    final categories = ['Todos', ...kProductCategories];
    var list = app.products.where((p) => _category == 'Todos' || p.category == _category).toList();
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((p) => p.name.toLowerCase().contains(q) || p.sku.toLowerCase().contains(q)).toList();
    }

    return BrandScreen(
      onRefresh: app.loadAll,
      // A diferencia del Dashboard, aquí NO queremos que el contenido
      // se recentre verticalmente al filtrar (se sentía raro que todo
      // saltara al centro con cada búsqueda). Las cajitas quedan fijas
      // arriba, como una lista normal.
      centerWhenShort: false,
      children: [
        BrandCard(
          child: Column(
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
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (list.isEmpty)
          const BrandCard(
            child: EmptyState(emoji: '📦', title: 'Sin piezas todavía', subtitle: 'Agrega la primera con el botón +'),
          )
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
    );
  }

  // Sin niveles de stock bajo por ahora: solo se marca en rojo cuando
  // llega a 0 (agotado); de lo contrario, se muestra el stock normal.
  Widget _stockChip(Product p) {
    if (p.stock <= 0) {
      return const StatusChip(label: 'Agotado', color: Colors.white, background: AppColors.spicyRed);
    }
    return StatusChip(
      label: '${p.stock} ${p.unit}',
      color: AppColors.success,
      background: AppColors.success.withOpacity(.12),
    );
  }
}