import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Bloque "shimmer" muy discreto para estados de carga — sin animación
/// infinita agresiva, solo un pulso suave de opacidad.
class LoadingSkeleton extends StatefulWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const LoadingSkeleton({super.key, this.height = 16, this.width, this.borderRadius});

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);
  late final Animation<double> _opacity = Tween(begin: .5, end: 1.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: c.surfaceAlt,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(AppRadius.control),
        ),
      ),
    );
  }
}

/// Placeholder de una fila tipo [ItemRow] mientras carga — mismo alto
/// y forma que la fila real, para que no "salte" el layout al llegar
/// los datos.
class ItemRowSkeleton extends StatelessWidget {
  const ItemRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      height: AppSizes.minTouchTarget + 24,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          const LoadingSkeleton(height: 44, width: 44, borderRadius: BorderRadius.all(Radius.circular(AppRadius.control))),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                LoadingSkeleton(height: 12, width: 140),
                SizedBox(height: 8),
                LoadingSkeleton(height: 10, width: 90),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
