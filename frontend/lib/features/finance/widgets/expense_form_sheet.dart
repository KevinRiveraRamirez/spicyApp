import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/expense.dart';
import '../../../state/app_state.dart';

const kExpenseCategories = ['Renta', 'Nómina', 'Maquila/Estampado', 'Marketing', 'Envíos', 'Otro'];

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
        const SizedBox(height: 12),
        TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Descripción (opcional)')),
        const SizedBox(height: 12),
        TextField(controller: _amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monto')),
        const SizedBox(height: 18),
        ElevatedButton(
          onPressed: _saving
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
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('GUARDAR'),
        ),
      ],
    );
  }
}
