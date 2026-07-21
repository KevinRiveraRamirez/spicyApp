class Product {
  final String id;
  final String name;
  final String category;
  final String sku;
  final String emoji;
  final double cost;
  final double price;
  final int stock;
  final int minStock;
  final String unit;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.sku,
    required this.emoji,
    required this.cost,
    required this.price,
    required this.stock,
    required this.minStock,
    required this.unit,
  });

  factory Product.fromMap(Map<String, dynamic> m) => Product(
        id: m['id'] as String,
        name: m['name'] as String,
        category: m['category'] as String? ?? 'Otro',
        sku: m['sku'] as String? ?? '',
        emoji: m['emoji'] as String? ?? '📦',
        cost: (m['cost'] as num?)?.toDouble() ?? 0,
        price: (m['price'] as num?)?.toDouble() ?? 0,
        stock: (m['stock'] as num?)?.toInt() ?? 0,
        minStock: (m['min_stock'] as num?)?.toInt() ?? 0,
        unit: m['unit'] as String? ?? 'pza',
      );

  Map<String, dynamic> toInsertMap({required String ownerId}) => {
        'owner_id': ownerId,
        'name': name,
        'category': category,
        'sku': sku,
        'emoji': emoji,
        'cost': cost,
        'price': price,
        'stock': stock,
        'min_stock': minStock,
        'unit': unit,
      };

  // Por ahora, sin niveles de "stock bajo": solo agotado (0) u ok.
  StockStatus get status => stock <= 0 ? StockStatus.out : StockStatus.ok;

  Product copyWith({
    String? name,
    String? category,
    String? sku,
    String? emoji,
    double? cost,
    double? price,
    int? stock,
    int? minStock,
    String? unit,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      sku: sku ?? this.sku,
      emoji: emoji ?? this.emoji,
      cost: cost ?? this.cost,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      unit: unit ?? this.unit,
    );
  }
}

enum StockStatus { ok, low, out }