import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/supplier.dart';
import '../../../state/app_state.dart';

class SupplierFormSheet extends StatefulWidget {
  const SupplierFormSheet({super.key});

  @override
  State<SupplierFormSheet> createState() => _SupplierFormSheetState();
}

class _SupplierFormSheetState extends State<SupplierFormSheet> {
  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _phone = TextEditingController();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Nombre del proveedor'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(controller: _contact, decoration: const InputDecoration(labelText: 'Contacto (opcional)')),
        const SizedBox(height: 12),
        TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Teléfono (opcional)')),
        const SizedBox(height: 18),
        ElevatedButton(
          onPressed: _saving || _name.text.trim().isEmpty
              ? null
              : () async {
                  setState(() => _saving = true);
                  try {
                    await context.read<AppState>().createSupplier(Supplier(
                          id: '',
                          name: _name.text.trim(),
                          contact: _contact.text.trim().isEmpty ? null : _contact.text.trim(),
                          phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
                        ));
                    if (mounted) Navigator.of(context).pop();
                  } finally {
                    if (mounted) setState(() => _saving = false);
                  }
                },
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('GUARDAR PROVEEDOR'),
        ),
      ],
    );
  }
}
