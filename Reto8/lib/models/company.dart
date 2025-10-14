class Company {
  int? id;
  String name;
  String website;
  String phone;
  String email;
  String products;
  String classification;

  Company({
    this.id,
    required this.name,
    required this.website,
    required this.phone,
    required this.email,
    required this.products,
    required this.classification,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'name': name,
      'website': website,
      'phone': phone,
      'email': email,
      'products': products,
      'classification': classification,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id'],
      name: map['name'],
      website: map['website'],
      phone: map['phone'],
      email: map['email'],
      products: map['products'],
      classification: map['classification'],
    );
  }
}
