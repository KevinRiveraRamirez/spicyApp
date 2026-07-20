import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../state/app_state.dart';
import '../../widgets/app_bottom_sheet.dart';
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

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: InkWell(
          onTap: () => AppBottomSheet.show(
            context,
            title: 'Configuración',
            child: SettingsSheet(onSignedOut: widget.onSignedOut, onLockNow: widget.onLockNow),
          ),
          child: Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: AppColors.spicyRed, borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: const Text('S', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SPICY', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                  Text(_titles[_index], style: const TextStyle(fontSize: 10.5, color: AppColors.asphalt, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Bloquear',
            onPressed: widget.onLockNow,
            icon: const Icon(Icons.lock_outline),
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
