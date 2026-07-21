import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/product.dart';
import '../../../services/sales_service.dart';
import '../../../state/app_state.dart';

class PosSheet extends StatefulWidget {
  const PosSheet({super.key});

  @override
  State<PosSheet> createState() => _PosSheetState();
}

class _PosSheetState extends State<PosSheet> {
  final List<CartLine> _cart = [];
  String _query = '';
  String _payment = 'Efectivo';
  bool _saving = false;

  double get _total => _cart.fold(0, (a, l) => a + l.subtotal);

  void _addProduct(Product p) {
    setState(() {
      final existing = _cart.where((l) => l.product.id == p.id).toList();
      if (existing.isNotEmpty) {
        if (existing.first.qty < p.stock) existing.first.qty++;
      } else {
        _cart.add(CartLine(product: p));
      }
    });
  }

  Future<void> _confirm() async {
    setState(() => _saving = true);
    try {
      await context.read<AppState>().registerSale(lines: _cart, paymentMethod: _payment);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final results = app.products
        .where((p) => p.stock > 0 && p.name.toLowerCase().contains(_query.toLowerCase()))
        .take(8)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: const InputDecoration(hintText: 'Buscar pieza...', prefixIcon: Icon(Icons.search, size: 20)),
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 150),
          child: ListView(
            shrinkWrap: true,
            children: results.map((p) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: InkWell(
                  onTap: () => _addProduct(p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.lightBorder),
                    ),
                    child: Row(
                      children: [
                        Text(p.emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                              Text('${p.stock} disp.', style: const TextStyle(fontSize: 11, color: AppColors.asphalt)),
                            ],
                          ),
                        ),
                        Text(Formatters.money(p.price), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        if (_cart.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text('Agrega piezas para iniciar la venta', style: TextStyle(color: AppColors.asphalt, fontSize: 12.5)),
          )
        else
          ..._cart.asMap().entries.map((entry) {
            final i = entry.key;
            final line = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(line.product.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        Text('${Formatters.money(line.product.price)} c/u', style: const TextStyle(fontSize: 11.5, color: AppColors.asphalt)),
                      ],
                    ),
                  ),
                  _Stepper(
                    qty: line.qty,
                    onDec: () => setState(() {
                      line.qty--;
                      if (line.qty <= 0) _cart.removeAt(i);
                    }),
                    onInc: () => setState(() {
                      if (line.qty < line.product.stock) line.qty++;
                    }),
                  ),
                ],
              ),
            );
          }),
        if (_cart.isNotEmpty) ...[
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _payment,
            decoration: const InputDecoration(labelText: 'Método de pago'),
            items: const ['Efectivo', 'Sinpe', 'Transferencia']
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (v) => setState(() => _payment = v ?? _payment),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(color: AppColors.asphalt, fontSize: 13)),
              Text(Formatters.money(_total), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _saving ? null : _confirm,
            child: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('COBRAR ${Formatters.money(_total)}'),
          ),
        ],
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  final int qty;
  final VoidCallback onDec;
  final VoidCallback onInc;
  const _Stepper({required this.qty, required this.onDec, required this.onInc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.lightSurfaceAlt, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          _btn('−', onDec),
          SizedBox(width: 22, child: Text('$qty', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700))),
          _btn('+', onInc),
        ],
      ),
    );
  }

  Widget _btn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 26, height: 26,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}