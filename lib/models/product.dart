class Product {
  final int id;
  final String name;
  final double price;
  final String description;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['title'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      image: json['image'],
    );
  }
}
