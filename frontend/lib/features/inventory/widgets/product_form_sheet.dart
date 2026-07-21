import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/product.dart';
import '../../../state/app_state.dart';

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
  late String _category;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _sku = TextEditingController(text: p?.sku ?? '');
    _cost = TextEditingController(text: p?.cost.toString() ?? '');
    _price = TextEditingController(text: p?.price.toString() ?? '');
    _stock = TextEditingController(text: p?.stock.toString() ?? '0');
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
      minStock: 0,
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
    await context.read<AppState>().deleteProduct(base.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nombre')),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: kProductCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: TextField(controller: _sku, decoration: const InputDecoration(labelText: 'SKU'))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: _cost, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Costo'))),
          const SizedBox(width: 10),
          Expanded(child: TextField(controller: _price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Precio venta'))),
        ]),
        const SizedBox(height: 12),
        TextField(controller: _stock, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock actual')),
        const SizedBox(height: 18),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('GUARDAR'),
        ),
        if (widget.product != null)
          TextButton(
            onPressed: _delete,
            child: const Text('ELIMINAR PIEZA', style: TextStyle(color: AppColors.spicyRed, fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }
}