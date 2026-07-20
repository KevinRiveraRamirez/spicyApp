class SaleItem {
  final String productId;
  final String productName;
  final int qty;
  final double price;

  const SaleItem({
    required this.productId,
    required this.productName,
    required this.qty,
    required this.price,
  });

  double get subtotal => qty * price;

  factory SaleItem.fromMap(Map<String, dynamic> m) => SaleItem(
        productId: m['product_id'] as String? ?? '',
        productName: m['product_name'] as String? ?? '',
        qty: (m['qty'] as num?)?.toInt() ?? 0,
        price: (m['price'] as num?)?.toDouble() ?? 0,
      );
}

class Sale {
  final String id;
  final DateTime soldAt;
  final String paymentMethod;
  final double total;
  final List<SaleItem> items;

  const Sale({
    required this.id,
    required this.soldAt,
    required this.paymentMethod,
    required this.total,
    this.items = const [],
  });

  factory Sale.fromMap(Map<String, dynamic> m) => Sale(
        id: m['id'] as String,
        soldAt: DateTime.parse(m['sold_at'] as String),
        paymentMethod: m['payment_method'] as String? ?? 'Efectivo',
        total: (m['total'] as num?)?.toDouble() ?? 0,
        items: (m['sale_items'] as List<dynamic>?)
                ?.map((e) => SaleItem.fromMap(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}
