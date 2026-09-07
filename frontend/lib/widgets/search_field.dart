import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Campo de búsqueda estándar — mismo alto que cualquier input (52dp,
/// ver [AppTheme]), con icono de búsqueda y botón de limpiar cuando
/// hay texto. Pensado para usarse "sticky" arriba de listas largas
/// (Inventario, historial de ventas/compras).
class SearchField extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  const SearchField({super.key, required this.hint, required this.onChanged, this.controller});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller = widget.controller ?? TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(() {
      final has = _controller.text.isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      textField: true,
      label: widget.hint,
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: Icon(Icons.search, size: 20, color: c.textSecondary),
          suffixIcon: _hasText
              ? IconButton(
                  tooltip: 'Limpiar búsqueda',
                  icon: Icon(Icons.close, size: 18, color: c.textSecondary),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                  },
                )
              : null,
        ),
      ),
    );
  }
}
