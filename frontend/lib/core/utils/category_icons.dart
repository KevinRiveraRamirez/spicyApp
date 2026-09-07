import 'package:flutter/material.dart';

/// Icono Material por categoría de producto — reemplaza los emojis que
/// usaba la versión anterior de la app. Los datos siguen guardando el
/// emoji original en la columna `emoji` (no se toca el esquema), esto
/// es puramente una decisión de presentación en el rediseño 2026.
const Map<String, IconData> kCategoryIcons = {
  'Accesorios': Icons.watch_outlined,
  'T-Shirt': Icons.checkroom_outlined,
  'Tenis': Icons.directions_run_outlined,
  'Suéter': Icons.ac_unit_outlined,
  'Pantalones': Icons.straighten_outlined,
  'Medias o Boxers': Icons.inventory_2_outlined,
};

IconData categoryIcon(String category) => kCategoryIcons[category] ?? Icons.category_outlined;
