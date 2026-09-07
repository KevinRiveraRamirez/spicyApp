import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text.dart';
import 'spicy_logo.dart';

enum NavLayout { bottom, rail, sidebar }

/// Un destino de navegación (una de las 5 pestañas principales).
class NavDestinationSpec {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavDestinationSpec({required this.icon, required this.activeIcon, required this.label});
}

/// Navegación principal de la app, con 3 formas según el ancho de
/// pantalla — nunca dos a la vez:
///  - [NavLayout.bottom]: barra inferior (teléfono, < 600dp).
///  - [NavLayout.rail]: riel compacto lateral (tablet, 600-1023dp).
///  - [NavLayout.sidebar]: barra lateral de 240dp, colapsable a 80dp
///    (escritorio/web, >= 1024dp).
class SpicyNavigation extends StatelessWidget {
  final NavLayout layout;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final List<NavDestinationSpec> destinations;
  final bool sidebarExpanded;
  final VoidCallback? onToggleSidebar;

  const SpicyNavigation({
    super.key,
    required this.layout,
    required this.selectedIndex,
    required this.onSelect,
    required this.destinations,
    this.sidebarExpanded = true,
    this.onToggleSidebar,
  });

  @override
  Widget build(BuildContext context) {
    switch (layout) {
      case NavLayout.bottom:
        return _bottom(context);
      case NavLayout.rail:
        return _rail(context);
      case NavLayout.sidebar:
        return _sidebar(context);
    }
  }

  Widget _bottom(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelect,
      destinations: [
        for (final d in destinations)
          NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.activeIcon), label: d.label),
      ],
    );
  }

  Widget _rail(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(border: Border(right: BorderSide(color: c.border))),
      child: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelect,
        labelType: NavigationRailLabelType.all,
        backgroundColor: c.surface,
        destinations: [
          for (final d in destinations)
            NavigationRailDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.activeIcon),
              label: Text(d.label),
            ),
        ],
      ),
    );
  }

  Widget _sidebar(BuildContext context) {
    final c = context.colors;
    final width = sidebarExpanded ? AppSizes.sidebarExpandedWidth : AppSizes.sidebarCollapsedWidth;
    return AnimatedContainer(
      duration: AppMotion.sheetOpen,
      curve: Curves.easeOutCubic,
      width: width,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(right: BorderSide(color: c.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
            child: sidebarExpanded
                ? SpicyWordmark(width: 96)
                : const Center(child: SpicyMonogram(size: 28)),
          ),
          const SizedBox(height: AppSpacing.md),
          for (int i = 0; i < destinations.length; i++) _sidebarItem(context, i),
          const Spacer(),
          if (onToggleSidebar != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Tooltip(
                message: sidebarExpanded ? 'Contraer menú' : 'Expandir menú',
                child: IconButton(
                  onPressed: onToggleSidebar,
                  icon: Icon(sidebarExpanded ? Icons.chevron_left : Icons.chevron_right, color: c.textSecondary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sidebarItem(BuildContext context, int i) {
    final c = context.colors;
    final d = destinations[i];
    final active = i == selectedIndex;
    final content = Row(
      children: [
        const SizedBox(width: AppSpacing.lg),
        Icon(active ? d.activeIcon : d.icon, size: 22, color: active ? c.brandPrimary : c.textSecondary),
        if (sidebarExpanded) ...[
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              d.label,
              style: AppTypography.bodyMedium.copyWith(
                color: active ? c.brandPrimary : c.textPrimary,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );

    final item = Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      child: Material(
        color: active ? c.brandPrimary.withOpacity(.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.control),
        child: InkWell(
          onTap: () => onSelect(i),
          borderRadius: BorderRadius.circular(AppRadius.control),
          child: SizedBox(height: AppSizes.minTouchTarget, child: content),
        ),
      ),
    );

    if (!sidebarExpanded) {
      return Tooltip(message: d.label, child: item);
    }
    return Semantics(button: true, selected: active, label: d.label, child: item);
  }
}
