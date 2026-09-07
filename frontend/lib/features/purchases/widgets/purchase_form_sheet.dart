import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/product.dart';
import '../../../models/supplier.dart';
import '../../../services/purchase_service.dart';
import '../../../state/app_state.dart';
import '../../../widgets/spicy_buttons.dart';
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
    final c = context.colors;
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
        const SizedBox(height: AppSpacing.lg),
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
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: c.success.withOpacity(.08),
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, size: 18, color: c.success),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text('Proveedor de Costa Rica: se registra directo en colones, sin tipo de cambio.',
                      style: AppTypography.label.copyWith(color: c.textSecondary)),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.xl),
        Text('Piezas', style: AppTypography.sectionTitle.copyWith(color: c.textPrimary, fontSize: 15)),
        const SizedBox(height: AppSpacing.sm),
        ..._lines.asMap().entries.map((entry) {
          final i = entry.key;
          final line = entry.value;
          final options = _productsInCategory(app, line.category);
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: c.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Pieza ${i + 1}', style: AppTypography.label.copyWith(color: c.textSecondary)),
                    ),
                    Semantics(
                      button: true,
                      label: 'Quitar pieza ${i + 1}',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => setState(() => _lines.removeAt(i)),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(Icons.close, size: 18, color: c.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  value: line.category,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: kProductCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (cat) => setState(() {
                    if (cat == null) return;
                    line.category = cat;
                    final opts = _productsInCategory(app, cat);
                    line.product = opts.isEmpty ? null : opts.first;
                  }),
                ),
                const SizedBox(height: AppSpacing.md),
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
                const SizedBox(height: AppSpacing.md),
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
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      width: 76,
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
        SecondaryButton(
          label: 'Agregar pieza',
          icon: Icons.add,
          onPressed: app.products.isEmpty ? null : () => _addLine(app),
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: c.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total estimado', style: AppTypography.body.copyWith(color: c.textSecondary)),
              _isForeign
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(Formatters.usd(_totalRaw), style: AppTypography.metric.copyWith(color: c.textPrimary, fontSize: 18)),
                        Text(Formatters.money(_totalCrc), style: AppTypography.label.copyWith(color: c.textSecondary)),
                      ],
                    )
                  : Text(Formatters.money(_totalCrc), style: AppTypography.metric.copyWith(color: c.textPrimary, fontSize: 18)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: 'Crear orden',
          loading: _saving,
          onPressed: (_supplier == null || !_linesValid || (_isForeign && _rate <= 0))
              ? null
              : () async {
                  setState(() => _saving = true);
                  try {
                    await app.createPurchase(
                      supplierId: _supplier!.id,
                      supplierName: _supplier!.name,
                      lines: _lines.map((l) => PurchaseLine(product: l.product!, qty: l.qty, cost: l.cost)).toList(),
                      currency: _isForeign ? 'USD' : 'CRC',
                      exchangeRate: _rate,
                    );
                    if (mounted) Navigator.of(context).pop();
                  } finally {
                    if (mounted) setState(() => _saving = false);
                  }
                },
        ),
      ],
    );
  }
}
