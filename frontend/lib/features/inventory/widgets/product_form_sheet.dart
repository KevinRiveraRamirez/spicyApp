import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/product.dart';
import '../../../state/app_state.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../widgets/spicy_buttons.dart';

const kProductCategories = ['Accesorios', 'T-Shirt', 'Tenis', 'Suéter', 'Pantalones', 'Medias o Boxers'];
const kProductEmojis = ['🎒', '👕', '👟', '🧥', '👖', '🧦'];

class ProductFormSheet extends StatefulWidget {
  final Product? product;
  const ProductFormSheet({super.key, this.product});

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  late final TextEditingController _name;
  late final TextEditingController _sku;
  late final TextEditingController _cost;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  late final TextEditingController _minStock;
  late String _category;
  bool _saving = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _sku = TextEditingController(text: p?.sku ?? '');
    _cost = TextEditingController(text: p?.cost.toString() ?? '');
    _price = TextEditingController(text: p?.price.toString() ?? '');
    _stock = TextEditingController(text: p?.stock.toString() ?? '0');
    _minStock = TextEditingController(text: (p?.minStock ?? 5).toString());
    // Si la pieza tiene una categoría vieja que ya no existe en la lista
    // (por ejemplo, de datos de ejemplo anteriores), cae de vuelta a la
    // primera categoría válida en vez de tronar el dropdown.
    _category = kProductCategories.contains(p?.category) ? p!.category : kProductCategories.first;
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final app = context.read<AppState>();
    final base = widget.product;
    final product = Product(
      id: base?.id ?? '',
      name: _name.text.trim(),
      category: _category,
      sku: _sku.text.trim().isEmpty ? 'SPC-${DateTime.now().millisecondsSinceEpoch % 1000}' : _sku.text.trim(),
      emoji: base?.emoji ?? kProductEmojis[DateTime.now().millisecond % kProductEmojis.length],
      cost: double.tryParse(_cost.text) ?? 0,
      price: double.tryParse(_price.text) ?? 0,
      stock: int.tryParse(_stock.text) ?? 0,
      minStock: int.tryParse(_minStock.text) ?? 0,
      unit: 'pza',
    );
    try {
      if (base == null) {
        await app.createProduct(product);
      } else {
        await app.updateProduct(product);
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final base = widget.product;
    if (base == null) return;
    final confirmed = await ConfirmDialog.show(
      context,
      title: '¿Eliminar pieza?',
      message: '${base.name} se quitará del inventario. Esta acción no se puede deshacer.',
    );
    if (!confirmed || !mounted) return;
    setState(() => _deleting = true);
    try {
      await context.read<AppState>().deleteProduct(base.id);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nombre')),
        const SizedBox(height: AppSpacing.md),
        Row(children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: kProductCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: TextField(controller: _sku, decoration: const InputDecoration(labelText: 'SKU'))),
        ]),
        const SizedBox(height: AppSpacing.md),
        Row(children: [
          Expanded(child: TextField(controller: _cost, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Costo'))),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: TextField(controller: _price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Precio venta'))),
        ]),
        const SizedBox(height: AppSpacing.md),
        Row(children: [
          Expanded(child: TextField(controller: _stock, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock actual'))),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: _minStock,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stock mínimo', helperText: 'Para avisar "poco stock"'),
            ),
          ),
        ]),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(label: 'Guardar', loading: _saving, onPressed: _save),
        if (widget.product != null) ...[
          const SizedBox(height: AppSpacing.sm),
          SecondaryButton(
            label: 'Eliminar pieza',
            icon: Icons.delete_outline,
            loading: _deleting,
            onPressed: _delete,
          ),
        ],
      ],
    );
  }
}
