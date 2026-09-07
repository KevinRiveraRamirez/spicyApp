import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/expense.dart';
import '../../../state/app_state.dart';
import '../../../widgets/spicy_buttons.dart';

const kExpenseCategories = ['Compra', 'Venta', 'Marketing', 'Transporte/Envíos', 'Otro'];

class ExpenseFormSheet extends StatefulWidget {
  const ExpenseFormSheet({super.key});

  @override
  State<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends State<ExpenseFormSheet> {
  String _category = kExpenseCategories.first;
  final _desc = TextEditingController();
  final _amount = TextEditingController();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          value: _category,
          decoration: const InputDecoration(labelText: 'Categoría'),
          items: kExpenseCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setState(() => _category = v ?? _category),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Descripción (opcional)')),
        const SizedBox(height: AppSpacing.md),
        TextField(controller: _amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monto'), onChanged: (_) => setState(() {})),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: 'Guardar',
          loading: _saving,
          onPressed: (double.tryParse(_amount.text) ?? 0) <= 0
              ? null
              : () async {
                  final amount = double.tryParse(_amount.text) ?? 0;
                  if (amount <= 0) return;
                  setState(() => _saving = true);
                  try {
                    await context.read<AppState>().createExpense(Expense(
                          id: '',
                          category: _category,
                          description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
                          amount: amount,
                          expenseDate: DateTime.now(),
                        ));
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
