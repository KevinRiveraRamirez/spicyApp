import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/category_icons.dart';
import '../../core/utils/formatters.dart';
import '../../models/product.dart';
import '../../state/app_state.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/brand_screen.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_chip_group.dart';
import '../../widgets/item_row.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/search_field.dart';
import '../../widgets/status_chip.dart';
import 'widgets/product_form_sheet.dart';

/// Inventario: buscador y filtros de categoría "sticky" arriba, y cada
/// pieza en su propia tarjeta compacta con categoría, SKU, costo,
/// precio, margen y estado de stock (disponible / poco stock /
/// agotado — usa el `min_stock` que ya vivía en la base de datos, sin
/// tocar el esquema).
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => InventoryScreenState();
}

class InventoryScreenState extends State<InventoryScreen> {
  String _query = '';
  String _category = 'Todos';

  void openNewProductSheet() {
    SpicyBottomSheet.show(context, title: 'Nueva pieza', child: const ProductFormSheet());
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final c = context.colors;
    final categories = ['Todos', ...kProductCategories];
    var list = app.products.where((p) => _category == 'Todos' || p.category == _category).toList();
    final hadAnyBeforeSearch = list.isNotEmpty;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((p) => p.name.toLowerCase().contains(q) || p.sku.toLowerCase().contains(q)).toList();
    }

    final header = Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        children: [
          SearchField(hint: 'Buscar pieza o SKU...', onChanged: (v) => setState(() => _query = v)),
          const SizedBox(height: AppSpacing.md),
          FilterChipGroup(
            options: categories,
            selected: _category,
            onSelected: (v) => setState(() => _category = v),
          ),
        ],
      ),
    );

    Widget body;
    if (app.isLoading && app.products.isEmpty) {
      body = Column(children: List.generate(5, (_) => const ItemRowSkeleton()));
    } else if (app.products.isEmpty) {
      body = const EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Sin piezas todavía',
        subtitle: 'Agrega la primera con el botón "Agregar producto"',
      );
    } else if (list.isEmpty) {
      body = EmptyState(
        icon: Icons.search_off,
        title: 'Sin resultados',
        subtitle: hadAnyBeforeSearch ? 'Nada coincide con "$_query"' : 'Sin piezas en esta categoría todavía',
      );
    } else {
      body = Column(
        children: list
            .map((p) => ItemRow(
                  leading: ItemThumb(icon: categoryIcon(p.category), foreground: c.brandPrimary, background: c.brandPrimary.withOpacity(.1)),
                  title: p.name,
                  subtitle: '${p.category} · SKU ${p.sku} · margen ${_marginLabel(p)}',
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(Formatters.money(p.price), style: AppTypography.bodyMedium.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      _stockChip(context, p),
                    ],
                  ),
                  onTap: () => SpicyBottomSheet.show(context, title: 'Editar pieza', child: ProductFormSheet(product: p)),
                ))
            .toList(),
      );
    }

    return SpicyScreen(onRefresh: app.loadAll, children: [header, body]);
  }

  String _marginLabel(Product p) {
    if (p.price <= 0) return '—';
    final margin = ((p.price - p.cost) / p.price) * 100;
    return '${margin.toStringAsFixed(0)}%';
  }

  // Disponible / poco stock / agotado — nunca depende solo del color,
  // siempre lleva texto.
  Widget _stockChip(BuildContext context, Product p) {
    final c = context.colors;
    if (p.stock <= 0) {
      return StatusChip(label: 'Agotado', color: c.danger, icon: Icons.remove_circle_outline);
    }
    if (p.minStock > 0 && p.stock <= p.minStock) {
      return StatusChip(label: 'Poco stock (${p.stock})', color: c.warning, icon: Icons.error_outline);
    }
    return StatusChip(label: 'Disponible (${p.stock})', color: c.success, icon: Icons.check_circle_outline);
  }
}
