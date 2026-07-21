import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/product.dart';
import '../../../models/supplier.dart';
import '../../../services/purchase_service.dart';
import '../../../state/app_state.dart';
import '../../inventory/widgets/product_form_sheet.dart' show kProductCategories;

/// Un renglón de la orden en construcción. Primero se elige la
/// categoría (para filtrar), luego la pieza específica dentro de esa
/// categoría — más fácil de encontrar que una lista plana de todo el
/// inventario.
class _LineDraft {
  String category;
  Product? product;
  int qty;
  double cost;
  _LineDraft({required this.category, this.product, this.qty = 1, this.cost = 0});
}

/// Formulario de nueva orden de compra. Si el proveedor es extranjero
/// (China/Estados Unidos, la mayoría), el costo de cada pieza se
/// ingresa en dólares y un tipo de cambio (editable) lo convierte a
/// colones. Si el proveedor es de Costa Rica, no aplica ningún tipo de
/// cambio: todo se ingresa y se guarda directo en colones.
class PurchaseFormSheet extends StatefulWidget {
  const PurchaseFormSheet({super.key});

  @override
  State<PurchaseFormSheet> createState() => _PurchaseFormSheetState();
}

class _PurchaseFormSheetState extends State<PurchaseFormSheet> {
  Supplier? _supplier;
  final List<_LineDraft> _lines = [];
  final _rateController = TextEditingController(text: '520');
  bool _saving = false;

  bool get _isForeign => _supplier?.isForeign ?? true;
  double get _rate => _isForeign ? (double.tryParse(_rateController.text.replaceAll(',', '.')) ?? 0) : 1;
  double get _totalRaw => _lines.fold(0, (a, l) => a + (l.qty * l.cost));
  double get _totalCrc => _isForeign ? _totalRaw * _rate : _totalRaw;
  bool get _linesValid => _lines.isNotEmpty && _lines.every((l) => l.product != null && l.cost > 0 && l.qty > 0);

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  List<Product> _productsInCategory(AppState app, String category) =>
      app.products.where((p) => p.category == category).toList();

  void _addLine(AppState app) {
    final category = kProductCategories.firstWhere(
      (c) => _productsInCategory(app, c).isNotEmpty,
      orElse: () => kProductCategories.first,
    );
    final options = _productsInCategory(app, category);
    setState(() => _lines.add(_LineDraft(category: category, product: options.isEmpty ? null : options.first)));
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (_supplier == null && app.suppliers.isNotEmpty) _supplier = app.suppliers.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<Supplier>(
          value: _supplier,
          decoration: const InputDecoration(labelText: 'Proveedor'),
          items: app.suppliers.map((s) => DropdownMenuItem(value: s, child: Text('${s.name} · ${s.origin}'))).toList(),
          onChanged: (v) => setState(() => _supplier = v),
        ),
        const SizedBox(height: 16),
        if (_isForeign)
          TextFormField(
            controller: _rateController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Tipo de cambio (₡ por \$)',
              helperText: 'Ajusta si el dólar cambió desde la última orden',
            ),
            onChanged: (_) => setState(() {}),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_outline, size: 18, color: AppColors.success),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Proveedor de Costa Rica: se registra directo en colones, sin tipo de cambio.',
                      style: TextStyle(fontSize: 12, color: AppColors.asphalt)),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        Text('Piezas', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 10),
        ..._lines.asMap().entries.map((entry) {
          final i = entry.key;
          final line = entry.value;
          final options = _productsInCategory(app, line.category);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Pieza ${i + 1}',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.asphalt, letterSpacing: .3)),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => setState(() => _lines.removeAt(i)),
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(Icons.close, size: 18, color: AppColors.asphalt),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: line.category,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: kProductCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (c) => setState(() {
                    if (c == null) return;
                    line.category = c;
                    final opts = _productsInCategory(app, c);
                    line.product = opts.isEmpty ? null : opts.first;
                  }),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Product>(
                  value: line.product,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Pieza',
                    hintText: options.isEmpty ? 'Sin productos en esta categoría' : null,
                  ),
                  items: options
                      .map((p) => DropdownMenuItem(value: p, child: Text(p.name, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: options.isEmpty ? null : (p) => setState(() => line.product = p),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: line.cost == 0 ? '' : line.cost.toString(),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: _isForeign ? 'Costo \$/u' : 'Costo ₡/u'),
                        onChanged: (v) => setState(() => line.cost = double.tryParse(v.replaceAll(',', '.')) ?? 0),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 70,
                      child: TextFormField(
                        initialValue: line.qty.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Cant.'),
                        onChanged: (v) => setState(() => line.qty = int.tryParse(v) ?? line.qty),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: app.products.isEmpty ? null : () => _addLine(app),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.spicyRed,
            side: const BorderSide(color: AppColors.lightBorder),
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Agregar pieza'),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total estimado', style: TextStyle(color: AppColors.asphalt, fontSize: 13)),
              _isForeign
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(Formatters.usd(_totalRaw), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                        Text(Formatters.money(_totalCrc), style: const TextStyle(fontSize: 12.5, color: AppColors.asphalt)),
                      ],
                    )
                  : Text(Formatters.money(_totalCrc), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ElevatedButton(
          onPressed: (_saving || _supplier == null || !_linesValid || (_isForeign && _rate <= 0))
              ? null
              : () async {
                  setState(() => _saving = true);
                  try {
                    await app.createPurchase(
                      supplierId: _supplier!.id,
                      supplierName: _supplier!.name,
                      lines: _lines
                          .map((l) => PurchaseLine(product: l.product!, qty: l.qty, cost: l.cost))
                          .toList(),
                      currency: _isForeign ? 'USD' : 'CRC',
                      exchangeRate: _rate,
                    );
                    if (mounted) Navigator.of(context).pop();
                  } finally {
                    if (mounted) setState(() => _saving = false);
                  }
                },
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('CREAR ORDEN'),
        ),
      ],
    );
  }
}