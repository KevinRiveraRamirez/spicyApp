import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../state/app_state.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/spicy_logo.dart';
import '../dashboard/dashboard_screen.dart';
import '../finance/finance_screen.dart';
import '../inventory/inventory_screen.dart';
import '../purchases/purchases_screen.dart';
import '../sales/sales_screen.dart';
import '../settings/settings_sheet.dart';

/// Shell principal: barra superior con marca, contenido de la pestaña
/// activa, FAB contextual (según la pestaña) y navegación inferior.
class RootShell extends StatefulWidget {
  final VoidCallback onSignedOut;
  final VoidCallback onLockNow;

  const RootShell({super.key, required this.onSignedOut, required this.onLockNow});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

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

  static const _titles = ['Panel del dueño', 'Inventario', 'Punto de venta', 'Compras y proveedores', 'Finanzas del negocio'];

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

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final screens = [
      DashboardScreen(onNavigate: (i) => setState(() => _index = i)),
      InventoryScreen(key: _inventoryKey),
      SalesScreen(key: _salesKey),
      PurchasesScreen(key: _purchasesKey),
      FinanceScreen(key: _financeKey),
    ];

    // Las pestañas ya rediseñadas (Dashboard, Inventario, Ventas, Compras)
    // pintan su propio fondo rojo de borde a borde (BrandScreen, igual
    // que lock/login), así que ahí la barra va transparente y "flota"
    // sobre ese mismo degradado — sin costura entre barra y contenido.
    // Las demás pestañas (aún sin rediseñar) conservan una barra clara.
    final usesBrandBg = _index == 0 || _index == 1 || _index == 2 || _index == 3;

    return Scaffold(
      extendBodyBehindAppBar: usesBrandBg,
      appBar: AppBar(
        titleSpacing: 20,
        backgroundColor: usesBrandBg ? Colors.transparent : Colors.white,
        foregroundColor: usesBrandBg ? Colors.white : AppColors.carbon,
        elevation: 0,
        systemOverlayStyle: usesBrandBg ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        title: Row(
          children: [
            usesBrandBg
                ? const SpicyLogo(width: 76)
                : const SpicyLogoBadge(
                    logoWidth: 46,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
            const SizedBox(width: 12),
            Text(_titles[_index],
                style: TextStyle(
                    fontSize: 11.5,
                    color: usesBrandBg ? Colors.white70 : AppColors.asphalt,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Configuración',
            onPressed: () => AppBottomSheet.show(
              context,
              title: 'Configuración',
              child: SettingsSheet(onSignedOut: widget.onSignedOut, onLockNow: widget.onLockNow),
            ),
            icon: Icon(Icons.settings_outlined, color: usesBrandBg ? Colors.white : AppColors.carbon),
          ),
          IconButton(
            tooltip: 'Bloquear',
            onPressed: widget.onLockNow,
            icon: Icon(Icons.lock_outline, color: usesBrandBg ? Colors.white : AppColors.carbon),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: app.isLoading && app.products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(index: _index, children: screens),
      floatingActionButton: _index == 0
          ? null
          : FloatingActionButton(
              onPressed: _onFabPressed,
              backgroundColor: AppColors.spicyRed,
              child: const Icon(Icons.add, color: Colors.white),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Inventario'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Ventas'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), activeIcon: Icon(Icons.local_shipping), label: 'Compras'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'Finanzas'),
        ],
      ),
    );
  }
}