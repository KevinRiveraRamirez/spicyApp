import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../state/app_state.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/error_state.dart';
import '../../widgets/spicy_buttons.dart';
import '../../widgets/spicy_navigation.dart';
import '../../widgets/spicy_top_bar.dart';
import '../dashboard/dashboard_screen.dart';
import '../finance/finance_screen.dart';
import '../inventory/inventory_screen.dart';
import '../purchases/purchases_screen.dart';
import '../sales/sales_screen.dart';
import '../settings/settings_sheet.dart';

/// Shell principal de la app ("SpicyAppShell"): barra superior,
/// contenido de la pestaña activa (siempre vivo vía [IndexedStack],
/// para no perder filtros ni scroll al cambiar de pestaña) y
/// navegación responsive — barra inferior en teléfono, riel en
/// tablet, sidebar colapsable en escritorio. Nunca dos formas de
/// navegación a la vez.
class SpicyAppShell extends StatefulWidget {
  final VoidCallback onSignedOut;
  final VoidCallback onLockNow;

  const SpicyAppShell({super.key, required this.onSignedOut, required this.onLockNow});

  @override
  State<SpicyAppShell> createState() => _SpicyAppShellState();
}

class _SpicyAppShellState extends State<SpicyAppShell> {
  int _index = 0;
  bool _sidebarExpanded = true;

  final _inventoryKey = GlobalKey<InventoryScreenState>();
  final _salesKey = GlobalKey<SalesScreenState>();
  final _purchasesKey = GlobalKey<PurchasesScreenState>();
  final _financeKey = GlobalKey<FinanceScreenState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadAll();
    });
  }

  static const _titles = ['Inicio', 'Inventario', 'Ventas', 'Compras', 'Finanzas'];

  static const _destinations = [
    NavDestinationSpec(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Inicio'),
    NavDestinationSpec(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2, label: 'Inventario'),
    NavDestinationSpec(icon: Icons.point_of_sale_outlined, activeIcon: Icons.point_of_sale, label: 'Ventas'),
    NavDestinationSpec(icon: Icons.local_shipping_outlined, activeIcon: Icons.local_shipping, label: 'Compras'),
    NavDestinationSpec(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet, label: 'Finanzas'),
  ];

  // Acción principal por pestaña: extendida y con etiqueta clara (no un
  // "+" ambiguo), alcanzable con el pulgar en móvil.
  ({IconData icon, String label})? get _fabSpec => switch (_index) {
        1 => (icon: Icons.add, label: 'Agregar producto'),
        2 => (icon: Icons.add, label: 'Nueva venta'),
        3 => (icon: Icons.add, label: 'Nueva compra'),
        4 => (icon: Icons.add, label: 'Registrar gasto'),
        _ => null,
      };

  void _onFabPressed() {
    switch (_index) {
      case 1:
        _inventoryKey.currentState?.openNewProductSheet();
        break;
      case 2:
        _salesKey.currentState?.openNewSaleSheet();
        break;
      case 3:
        _purchasesKey.currentState?.openNewPurchaseSheet();
        break;
      case 4:
        _financeKey.currentState?.openNewExpenseSheet();
        break;
    }
  }

  void _openSettings() {
    SpicyBottomSheet.show(
      context,
      title: 'Configuración',
      child: SettingsSheet(onSignedOut: widget.onSignedOut, onLockNow: widget.onLockNow),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final c = context.colors;
    final screens = [
      DashboardScreen(onNavigate: (i) => setState(() => _index = i)),
      InventoryScreen(key: _inventoryKey),
      SalesScreen(key: _salesKey),
      PurchasesScreen(key: _purchasesKey),
      FinanceScreen(key: _financeKey, onNavigateToSales: () => setState(() => _index = 2)),
    ];

    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppSizes.breakpointDesktop;
    final isTablet = width >= AppSizes.breakpointTablet;
    final fab = _fabSpec;

    final topBarActions = [
      IconButton(
        tooltip: 'Configuración',
        onPressed: _openSettings,
        icon: Icon(Icons.settings_outlined, color: c.textSecondary),
      ),
      IconButton(
        tooltip: 'Bloquear',
        onPressed: widget.onLockNow,
        icon: Icon(Icons.lock_outline, color: c.textSecondary),
      ),
    ];

    final body = app.loadError != null && app.products.isEmpty
        ? Center(
            child: ErrorState(
              title: 'No se pudo cargar tu tienda',
              subtitle: app.loadError,
              onRetry: app.loadAll,
            ),
          )
        : app.isLoading && app.products.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : IndexedStack(index: _index, children: screens);

    Widget floatingAction() {
      if (fab == null) return const SizedBox.shrink();
      return FloatingActionButton.extended(
        onPressed: _onFabPressed,
        backgroundColor: c.brandPrimary,
        foregroundColor: Colors.white,
        icon: Icon(fab.icon),
        label: Text(fab.label, style: const TextStyle(fontWeight: FontWeight.w700)),
      );
    }

    // Teléfono: navegación inferior fija.
    if (!isTablet) {
      return Scaffold(
        appBar: SpicyTopBar(title: _titles[_index], actions: topBarActions),
        body: body,
        floatingActionButton: floatingAction(),
        bottomNavigationBar: SpicyNavigation(
          layout: NavLayout.bottom,
          selectedIndex: _index,
          onSelect: (i) => setState(() => _index = i),
          destinations: _destinations,
        ),
      );
    }

    // Tablet: riel compacto lateral. Escritorio: sidebar colapsable.
    final nav = SpicyNavigation(
      layout: isDesktop ? NavLayout.sidebar : NavLayout.rail,
      selectedIndex: _index,
      onSelect: (i) => setState(() => _index = i),
      destinations: _destinations,
      sidebarExpanded: _sidebarExpanded,
      onToggleSidebar: isDesktop ? () => setState(() => _sidebarExpanded = !_sidebarExpanded) : null,
    );

    if (isDesktop) {
      // En escritorio no usamos un AppBar que cruce todo el ancho (eso
      // duplicaba el título contra el saludo/encabezado del propio
      // contenido, ver ajustes 2026). En su lugar, una sola barra vive
      // dentro de la columna de contenido, a la derecha del sidebar, y
      // ahí mismo va el botón de acción principal (ya no un FAB flotando
      // lejos del contenido en monitores grandes).
      final headerButton = fab == null
          ? null
          : PrimaryButton(label: fab.label, icon: fab.icon, onPressed: _onFabPressed);
      return Scaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            nav,
            Expanded(
              child: Column(
                children: [
                  SpicyContentHeader(
                    // Inicio ya muestra su propio saludo dentro del
                    // contenido — repetir "Inicio" aquí sería la
                    // duplicación que se pidió eliminar.
                    title: _index == 0 ? null : _titles[_index],
                    titleIcon: _index == 0 ? null : _destinations[_index].activeIcon,
                    primaryAction: headerButton,
                    actions: topBarActions,
                  ),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Tablet: riel lateral compacto (sin logo propio), AppBar clásico
    // arriba y FAB extendido — aquí no hay conflicto de duplicación.
    return Scaffold(
      appBar: SpicyTopBar(title: _titles[_index], actions: topBarActions),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          nav,
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingAction(),
    );
  }
}
