const kSupplierOrigins = ['China', 'Estados Unidos', 'Costa Rica'];

class Supplier {
  final String id;
  final String name;
  final String? contact;
  final String? phone;
  /// Enlace de referencia: página del proveedor en Alibaba/1688,
  /// WhatsApp, sitio web, etc.
  final String? link;
  /// De dónde es el proveedor. Determina si sus órdenes de compra se
  /// registran en dólares con tipo de cambio (China/Estados Unidos) o
  /// directo en colones sin conversión (Costa Rica).
  final String origin;

  const Supplier({
    required this.id,
    required this.name,
    this.contact,
    this.phone,
    this.link,
    this.origin = 'China',
  });

  bool get isForeign => origin != 'Costa Rica';

  factory Supplier.fromMap(Map<String, dynamic> m) => Supplier(
        id: m['id'] as String,
        name: m['name'] as String,
        contact: m['contact'] as String?,
        phone: m['phone'] as String?,
        link: m['link'] as String?,
        origin: (m['origin'] as String?) ?? 'China',
      );

  Map<String, dynamic> toInsertMap({required String ownerId}) => {
        'owner_id': ownerId,
        'name': name,
        'contact': contact,
        'phone': phone,
        'link': link,
        'origin': origin,
      };
}