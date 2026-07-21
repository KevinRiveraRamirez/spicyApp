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
  final _link = TextEditingController();
  String _origin = kSupplierOrigins.first;
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
        DropdownButtonFormField<String>(
          value: _origin,
          decoration: const InputDecoration(
            labelText: 'País de origen',
            helperText: 'Costa Rica se maneja solo en colones, sin tipo de cambio',
          ),
          items: kSupplierOrigins.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: (v) => setState(() => _origin = v ?? _origin),
        ),
        const SizedBox(height: 12),
        TextField(controller: _contact, decoration: const InputDecoration(labelText: 'Contacto (opcional)')),
        const SizedBox(height: 12),
        TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Teléfono (opcional)')),
        const SizedBox(height: 12),
        TextField(
          controller: _link,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Link (opcional)',
            helperText: 'Alibaba, 1688, WhatsApp, sitio web, etc.',
          ),
        ),
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
                          link: _link.text.trim().isEmpty ? null : _link.text.trim(),
                          origin: _origin,
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