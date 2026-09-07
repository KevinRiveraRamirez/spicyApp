import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/product.dart';
import '../models/purchase.dart';
import '../models/sale.dart';
import '../models/supplier.dart';
import '../services/expense_service.dart';
import '../services/product_service.dart';
import '../services/purchase_service.dart';
import '../services/sales_service.dart';
import '../services/supplier_service.dart';

/// Estado central de la app: mantiene en memoria los datos ya cargados
/// de Supabase y expone acciones de alto nivel a las pantallas. Se
/// registra como Provider en main.dart.
class AppState extends ChangeNotifier {
  final _productService = ProductService();
  final _supplierService = SupplierService();
  final _salesService = SalesService();
  final _purchaseService = PurchaseService();
  final _expenseService = ExpenseService();

  bool isLoading = false;
  bool darkMode = false;
  // Mensaje amigable si la última carga falló (conexión, Supabase
  // pausado, etc.) — puramente informativo, no cambia el resto del
  // flujo. Las pantallas lo usan para mostrar un ErrorState con
  // "Reintentar" en vez de quedarse en blanco.
  String? loadError;

  List<Product> products = [];
  List<Supplier> suppliers = [];
  List<Sale> sales = [];
  List<Purchase> purchases = [];
  List<Expense> expenses = [];

  Future<void> loadAll() async {
    isLoading = true;
    loadError = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _productService.fetchAll(),
        _supplierService.fetchAll(),
        _salesService.fetchAll(),
        _purchaseService.fetchAll(),
        _expenseService.fetchAll(),
      ]);
      products = results[0] as List<Product>;
      suppliers = results[1] as List<Supplier>;
      sales = results[2] as List<Sale>;
      purchases = results[3] as List<Purchase>;
      expenses = results[4] as List<Expense>;
    } catch (_) {
      loadError = 'No se pudo cargar la información. Revisa tu conexión e intenta de nuevo.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void toggleDarkMode() {
    darkMode = !darkMode;
    notifyListeners();
  }

  // ---- Productos ----
  Future<void> createProduct(Product p) async {
    final created = await _productService.create(p);
    products = [...products, created];
    notifyListeners();
  }

  Future<void> updateProduct(Product p) async {
    final updated = await _productService.update(p);
    products = products.map((x) => x.id == updated.id ? updated : x).toList();
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    await _productService.delete(id);
    products = products.where((x) => x.id != id).toList();
    notifyListeners();
  }

  // ---- Ventas ----
  /// Registra la venta y devuelve el registro ya creado (para que la
  /// pantalla de confirmación pueda ofrecer "ver detalle" de esta
  /// venta exacta, sin adivinar cuál es en la lista recién recargada).
  Future<Sale> registerSale({
    required List<CartLine> lines,
    required String paymentMethod,
  }) async {
    final newSaleId = await _salesService.registerSale(lines: lines, paymentMethod: paymentMethod);
    // Refresca ventas y productos (el stock cambió en el servidor).
    final results = await Future.wait([
      _salesService.fetchAll(),
      _productService.fetchAll(),
    ]);
    sales = results[0] as List<Sale>;
    products = results[1] as List<Product>;
    notifyListeners();
    return sales.firstWhere((s) => s.id == newSaleId, orElse: () => sales.first);
  }

  // ---- Compras ----
  Future<void> createPurchase({
    required String supplierId,
    required String supplierName,
    required List<PurchaseLine> lines,
    required String currency,
    double exchangeRate = 1,
  }) async {
    await _purchaseService.create(
      supplierId: supplierId,
      supplierName: supplierName,
      lines: lines,
      currency: currency,
      exchangeRate: exchangeRate,
    );
    purchases = await _purchaseService.fetchAll();
    notifyListeners();
  }

  Future<void> markPurchaseInTransit(String purchaseId) async {
    await _purchaseService.markInTransit(purchaseId);
    purchases = await _purchaseService.fetchAll();
    notifyListeners();
  }

  Future<void> receivePurchase(String purchaseId) async {
    await _purchaseService.receive(purchaseId);
    final results = await Future.wait([
      _purchaseService.fetchAll(),
      _productService.fetchAll(),
    ]);
    purchases = results[0] as List<Purchase>;
    products = results[1] as List<Product>;
    notifyListeners();
  }

  Future<void> createSupplier(Supplier s) async {
    final created = await _supplierService.create(s);
    suppliers = [...suppliers, created];
    notifyListeners();
  }

  Future<void> deleteSupplier(String id) async {
    await _supplierService.delete(id);
    suppliers = suppliers.where((x) => x.id != id).toList();
    notifyListeners();
  }

  // ---- Gastos ----
  Future<void> createExpense(Expense e) async {
    final created = await _expenseService.create(e);
    expenses = [created, ...expenses];
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    await _expenseService.delete(id);
    expenses = expenses.where((x) => x.id != id).toList();
    notifyListeners();
  }
}
