class PurchaseItem {
  final String? productId;
  final String productName;
  final int qty;
  final double cost;
  final double costUsd;

  const PurchaseItem({
    this.productId,
    required this.productName,
    required this.qty,
    required this.cost,
    this.costUsd = 0,
  });

  double get subtotal => qty * cost;
  double get subtotalUsd => qty * costUsd;

  factory PurchaseItem.fromMap(Map<String, dynamic> m) => PurchaseItem(
        productId: m['product_id'] as String?,
        productName: m['product_name'] as String? ?? '',
        qty: (m['qty'] as num?)?.toInt() ?? 0,
        cost: (m['cost'] as num?)?.toDouble() ?? 0,
        costUsd: (m['cost_usd'] as num?)?.toDouble() ?? 0,
      );
}

/// Flujo real de una compra a proveedor (mayoría en China): se hace el
/// pedido, viaja (barco/avión) hasta Costa Rica, y se recibe en bodega.
enum PurchaseStatus { pedido, enTransito, recibida }

extension PurchaseStatusX on PurchaseStatus {
  static PurchaseStatus fromDb(String? s) {
    switch (s) {
      case 'En tránsito':
        return PurchaseStatus.enTransito;
      case 'Recibida':
        return PurchaseStatus.recibida;
      default:
        return PurchaseStatus.pedido;
    }
  }

  String get dbValue => switch (this) {
        PurchaseStatus.pedido => 'Pedido',
        PurchaseStatus.enTransito => 'En tránsito',
        PurchaseStatus.recibida => 'Recibida',
      };

  String get label => dbValue;
}

class Purchase {
  final String id;
  final String supplierName;
  final PurchaseStatus status;
  final double total;
  final double totalUsd;
  final double exchangeRate;
  /// 'USD' (proveedor extranjero, con tipo de cambio) o 'CRC' (proveedor
  /// de Costa Rica, todo directo en colones, sin conversión).
  final String currency;
  final DateTime orderedAt;
  final List<PurchaseItem> items;

  const Purchase({
    required this.id,
    required this.supplierName,
    required this.status,
    required this.total,
    this.totalUsd = 0,
    this.exchangeRate = 0,
    this.currency = 'USD',
    required this.orderedAt,
    this.items = const [],
  });

  bool get isUsd => currency == 'USD';

  factory Purchase.fromMap(Map<String, dynamic> m) => Purchase(
        id: m['id'] as String,
        supplierName: m['supplier_name'] as String? ?? '',
        status: PurchaseStatusX.fromDb(m['status'] as String?),
        total: (m['total'] as num?)?.toDouble() ?? 0,
        totalUsd: (m['total_usd'] as num?)?.toDouble() ?? 0,
        exchangeRate: (m['exchange_rate'] as num?)?.toDouble() ?? 0,
        currency: (m['currency'] as String?) ?? 'USD',
        orderedAt: DateTime.parse(m['ordered_at'] as String),
        items: (m['purchase_items'] as List<dynamic>?)
                ?.map((e) => PurchaseItem.fromMap(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}