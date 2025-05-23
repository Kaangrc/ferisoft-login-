class ProductModel {
  final int id;
  final String productName;
  final String productDescription;
  final double productPrice;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_name': productName,
        'product_description': productDescription,
        'product_price': productPrice,
        'image_url': imageUrl,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      productName: json['product_name'],
      productDescription: json['product_description'],
      productPrice: double.parse(json['product_price'].toString()),
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
