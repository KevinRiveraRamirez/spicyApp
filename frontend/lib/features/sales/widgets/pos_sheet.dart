import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/product.dart';
import '../../../models/sale.dart';
import '../../../services/sales_service.dart';
import '../../../state/app_state.dart';
import '../../../widgets/spicy_buttons.dart';
import 'sale_detail_sheet.dart';

enum _PosStep { cart, checkout, success }

/// Estado compartido entre [PosBody] (contenido desplazable, cambia
/// según el paso) y [PosFooter] (barra inferior sticky con el total y
/// el botón principal) — ambos widgets se pasan por separado a
/// [SpicyBottomSheet] para que el CTA quede siempre visible sobre el
/// teclado, incluso mientras el usuario busca piezas.
class PosController extends ChangeNotifier {
  final AppState appState;
  PosController(this.appState);

  _PosStep step = _PosStep.cart;
  final List<CartLine> cart = [];
  String query = '';
  String paymentMethod = 'Efectivo';
  bool saving = false;
  Sale? completedSale;

  double get total => cart.fold(0, (a, l) => a + l.subtotal);
  int get itemCount => cart.fold(0, (a, l) => a + l.qty);

  void setQuery(String v) {
    query = v;
    notifyListeners();
  }

  void addProduct(Product p) {
    final existing = cart.where((l) => l.product.id == p.id).toList();
    if (existing.isNotEmpty) {
      if (existing.first.qty < p.stock) existing.first.qty++;
    } else {
      cart.add(CartLine(product: p));
    }
    notifyListeners();
  }

  void incLine(CartLine line) {
    if (line.qty < line.product.stock) line.qty++;
    notifyListeners();
  }

  void decLine(CartLine line) {
    line.qty--;
    if (line.qty <= 0) cart.remove(line);
    notifyListeners();
  }

  void setPaymentMethod(String m) {
    paymentMethod = m;
    notifyListeners();
  }

  void goToCheckout() {
    if (cart.isEmpty) return;
    step = _PosStep.checkout;
    notifyListeners();
  }

  void backToCart() {
    step = _PosStep.cart;
    notifyListeners();
  }

  Future<void> confirm() async {
    if (saving) return; // bloquea doble toque durante el registro
    saving = true;
    notifyListeners();
    try {
      final sale = await appState.registerSale(lines: cart, paymentMethod: paymentMethod);
      completedSale = sale;
      step = _PosStep.success;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  void reset() {
    cart.clear();
    query = '';
    completedSale = null;
    step = _PosStep.cart;
    notifyListeners();
  }
}

/// Contenido desplazable del sheet: cambia según el paso (buscar/
/// carrito → revisar y elegir método → confirmación).
class PosBody extends StatelessWidget {
  final PosController controller;
  const PosBody({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: switch (controller.step) {
            _PosStep.cart => _CartStep(key: const ValueKey('cart'), controller: controller),
            _PosStep.checkout => _CheckoutStep(key: const ValueKey('checkout'), controller: controller),
            _PosStep.success => _SuccessStep(key: const ValueKey('success'), controller: controller),
          },
        );
      },
    );
  }
}

/// Barra inferior sticky: total + cantidad de piezas siempre visibles,
/// con el botón principal de cada paso.
class PosFooter extends StatelessWidget {
  final PosController controller;
  const PosFooter({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.step == _PosStep.success) {
          return Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Ver detalle',
                  icon: Icons.receipt_long_outlined,
                  onPressed: controller.completedSale == null
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          SaleDetailSheet.open(context, controller.completedSale!);
                        },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: PrimaryButton(label: 'Nueva venta', icon: Icons.add, onPressed: controller.reset),
              ),
            ],
          );
        }

        final totalRow = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              controller.itemCount == 0 ? 'Carrito vacío' : '${controller.itemCount} pieza(s)',
              style: AppTypography.label.copyWith(color: c.textSecondary),
            ),
            Text(Formatters.money(controller.total), style: AppTypography.metric.copyWith(color: c.textPrimary, fontSize: 20)),
          ],
        );

        if (controller.step == _PosStep.cart) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              totalRow,
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(
                label: 'Continuar',
                icon: Icons.arrow_forward,
                onPressed: controller.cart.isEmpty ? null : controller.goToCheckout,
              ),
            ],
          );
        }

        // checkout
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            totalRow,
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                SizedBox(
                  width: 96,
                  child: SecondaryButton(label: 'Atrás', onPressed: controller.saving ? null : controller.backToCart),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: PrimaryButton(
                    label: 'Cobrar ${Formatters.money(controller.total)}',
                    icon: Icons.check_circle_outline,
                    loading: controller.saving,
                    onPressed: controller.confirm,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _CartStep extends StatelessWidget {
  final PosController controller;
  const _CartStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = controller.appState;
    final results = app.products
        .where((p) => p.stock > 0 && p.name.toLowerCase().contains(controller.query.toLowerCase()))
        .take(8)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          decoration: const InputDecoration(hintText: 'Buscar pieza...', prefixIcon: Icon(Icons.search, size: 20)),
          onChanged: controller.setQuery,
        ),
        const SizedBox(height: AppSpacing.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 160),
          child: ListView(
            shrinkWrap: true,
            children: results.map((p) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: InkWell(
                  onTap: () => controller.addProduct(p),
                  borderRadius: BorderRadius.circular(AppRadius.control),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      border: Border.all(color: c.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline, color: c.brandPrimary, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: AppTypography.bodyMedium.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
                              Text('${p.stock} disp.', style: AppTypography.label.copyWith(color: c.textSecondary)),
                            ],
                          ),
                        ),
                        Text(Formatters.money(p.price), style: AppTypography.bodyMedium.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (controller.cart.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text('Agrega piezas para iniciar la venta', style: AppTypography.body.copyWith(color: c.textSecondary)),
          )
        else
          ...controller.cart.map((line) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(line.product.name, style: AppTypography.bodyMedium.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
                        Text('${Formatters.money(line.product.price)} c/u', style: AppTypography.label.copyWith(color: c.textSecondary)),
                      ],
                    ),
                  ),
                  _Stepper(qty: line.qty, onDec: () => controller.decLine(line), onInc: () => controller.incLine(line)),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _CheckoutStep extends StatelessWidget {
  final PosController controller;
  const _CheckoutStep({super.key, required this.controller});

  static const _methods = ['Efectivo', 'Sinpe', 'Transferencia'];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Resumen de la venta', style: AppTypography.sectionTitle.copyWith(color: c.textPrimary, fontSize: 15)),
        const SizedBox(height: AppSpacing.sm),
        ...controller.cart.map((line) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(child: Text('${line.qty}× ${line.product.name}', style: AppTypography.body.copyWith(color: c.textPrimary))),
                  Text(Formatters.money(line.subtotal), style: AppTypography.bodyMedium.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
                ],
              ),
            )),
        const SizedBox(height: AppSpacing.lg),
        Text('Método de pago', style: AppTypography.sectionTitle.copyWith(color: c.textPrimary, fontSize: 15)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: _methods.map((m) {
            final active = controller.paymentMethod == m;
            return ChoiceChip(
              label: Text(m),
              selected: active,
              selectedColor: c.brandPrimary,
              labelStyle: AppTypography.label.copyWith(color: active ? Colors.white : c.textPrimary),
              onSelected: (_) => controller.setPaymentMethod(m),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SuccessStep extends StatelessWidget {
  final PosController controller;
  const _SuccessStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final sale = controller.completedSale;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 56, color: c.success),
          const SizedBox(height: AppSpacing.md),
          Text('Venta registrada', style: AppTypography.screenTitle.copyWith(color: c.textPrimary)),
          const SizedBox(height: AppSpacing.xs),
          if (sale != null)
            Text(
              '${Formatters.money(sale.total)} · ${sale.paymentMethod}',
              style: AppTypography.body.copyWith(color: c.textSecondary),
            ),
        ],
      ),
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
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: c.surfaceAlt, borderRadius: BorderRadius.circular(AppRadius.control)),
      child: Row(
        children: [
          _btn(context, Icons.remove, onDec, 'Quitar una unidad'),
          SizedBox(width: 26, child: Text('$qty', textAlign: TextAlign.center, style: AppTypography.bodyMedium.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700))),
          _btn(context, Icons.add, onInc, 'Agregar una unidad'),
        ],
      ),
    );
  }

  Widget _btn(BuildContext context, IconData icon, VoidCallback onTap, String label) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(8)),
          alignment: Alignment.center,
          child: Icon(icon, size: 15, color: c.textPrimary),
        ),
      ),
    );
  }
}
