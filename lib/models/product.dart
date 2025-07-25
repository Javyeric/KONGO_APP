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
}
