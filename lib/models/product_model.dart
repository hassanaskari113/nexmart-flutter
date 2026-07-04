import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  // fields
  final String productId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int stock;
  final double rating;
  final DateTime createdAt;

  // constructor
  const ProductModel({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
    required this.rating,
    required this.createdAt,
  });

  // convert object to Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'stock': stock,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // convert Map from Firestore back to UserModel object
  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      productId: id,
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      description: map['description'],
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'],
      stock: (map['stock'] as num).toInt(),
      rating: (map['rating'] as num).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
