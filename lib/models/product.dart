class Product {
  final String name;
  final String size;
  final double price;
  final String category;
  final String type;
  final String? image;

  Product({
    required this.name,
    required this.size,
    required this.price,
    required this.category,
    required this.type,
    this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] as String,
      size: json['size'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      type: json['type'] as String,
      image: json['image'] as String?,
    );
  }
}
