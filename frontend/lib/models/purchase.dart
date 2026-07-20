class PurchaseItem {
  final String? productId;
  final String productName;
  final int qty;
  final double cost;

  const PurchaseItem({
    this.productId,
    required this.productName,
    required this.qty,
    required this.cost,
  });

  double get subtotal => qty * cost;

  factory PurchaseItem.fromMap(Map<String, dynamic> m) => PurchaseItem(
        productId: m['product_id'] as String?,
        productName: m['product_name'] as String? ?? '',
        qty: (m['qty'] as num?)?.toInt() ?? 0,
        cost: (m['cost'] as num?)?.toDouble() ?? 0,
      );
}

enum PurchaseStatus { pendiente, recibida }

class Purchase {
  final String id;
  final String supplierName;
  final PurchaseStatus status;
  final double total;
  final DateTime orderedAt;
  final List<PurchaseItem> items;

  const Purchase({
    required this.id,
    required this.supplierName,
    required this.status,
    required this.total,
    required this.orderedAt,
    this.items = const [],
  });

  factory Purchase.fromMap(Map<String, dynamic> m) => Purchase(
        id: m['id'] as String,
        supplierName: m['supplier_name'] as String? ?? '',
        status: (m['status'] as String?) == 'Recibida'
            ? PurchaseStatus.recibida
            : PurchaseStatus.pendiente,
        total: (m['total'] as num?)?.toDouble() ?? 0,
        orderedAt: DateTime.parse(m['ordered_at'] as String),
        items: (m['purchase_items'] as List<dynamic>?)
                ?.map((e) => PurchaseItem.fromMap(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}
