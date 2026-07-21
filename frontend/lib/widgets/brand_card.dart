import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// "Cajita" blanca de contenido usada sobre el fondo de marca
/// ([BrandScreen]): tarjeta redondeada con título opcional, acción a
/// la derecha (ej. "Ver todo") y el contenido debajo.
class BrandCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? action;
  final EdgeInsets padding;

  const BrandCard({
    super.key,
    this.title,
    required this.child,
    this.action,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.carbon)),
                if (action != null) action!,
              ],
            ),
          if (title != null) const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}