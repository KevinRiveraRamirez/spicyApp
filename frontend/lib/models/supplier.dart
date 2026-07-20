class Supplier {
  final String id;
  final String name;
  final String? contact;
  final String? phone;

  const Supplier({
    required this.id,
    required this.name,
    this.contact,
    this.phone,
  });

  factory Supplier.fromMap(Map<String, dynamic> m) => Supplier(
        id: m['id'] as String,
        name: m['name'] as String,
        contact: m['contact'] as String?,
        phone: m['phone'] as String?,
      );

  Map<String, dynamic> toInsertMap({required String ownerId}) => {
        'owner_id': ownerId,
        'name': name,
        'contact': contact,
        'phone': phone,
      };
}
