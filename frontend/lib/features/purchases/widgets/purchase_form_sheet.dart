import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/product.dart';
import '../../../models/supplier.dart';
import '../../../services/purchase_service.dart';
import '../../../state/app_state.dart';

class PurchaseFormSheet extends StatefulWidget {
  const PurchaseFormSheet({super.key});

  @override
  State<PurchaseFormSheet> createState() => _PurchaseFormSheetState();
}

class _PurchaseFormSheetState extends State<PurchaseFormSheet> {
  Supplier? _supplier;
  final List<PurchaseLine> _lines = [];
  bool _saving = false;

  double get _total => _lines.fold(0, (a, l) => a + l.subtotal);

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
          items: app.suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
          onChanged: (v) => setState(() => _supplier = v),
        ),
        const SizedBox(height: 12),
        ..._lines.asMap().entries.map((entry) {
          final i = entry.key;
          final line = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Product>(
                    value: line.product,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Pieza'),
                    items: app.products
                        .map((p) => DropdownMenuItem(value: p, child: Text(p.name, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (p) => setState(() {
                      if (p != null) _lines[i] = PurchaseLine(product: p, qty: line.qty);
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    initialValue: line.qty.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Cant.'),
                    onChanged: (v) => line.qty = int.tryParse(v) ?? line.qty,
                  ),
                ),
              ],
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: app.products.isEmpty
                ? null
                : () => setState(() => _lines.add(PurchaseLine(product: app.products.first))),
            child: const Text('+ Agregar pieza'),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total estimado', style: TextStyle(color: AppColors.asphalt, fontSize: 13)),
            Text(Formatters.money(_total), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
          ],
        ),
        const SizedBox(height: 14),
        ElevatedButton(
          onPressed: (_saving || _supplier == null || _lines.isEmpty)
              ? null
              : () async {
                  setState(() => _saving = true);
                  try {
                    await app.createPurchase(
                      supplierId: _supplier!.id,
                      supplierName: _supplier!.name,
                      lines: _lines,
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
