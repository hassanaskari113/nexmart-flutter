import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexmart/models/cart_item_model.dart';
import 'package:nexmart/models/product_model.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final List<CartItemModel> items;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final String fullName;
  final String phoneNumber;
  final String address;
  final String city;

  const OrderModel({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.city,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'items': items.map((item) {
        return {'product': item.product.toMap(), 'quantity': item.quantity};
      }).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String userOrderId) {
    return OrderModel(
      orderId: userOrderId,
      userId: map['userId'],
      items: (map['items'] as List).map((i) {
        return CartItemModel(
          product: ProductModel.fromMap(i['product'], i['product']['productId']),
          quantity: i['quantity'],
        );
      }).toList(),
      totalAmount: map['totalAmount'],
      status: map['status'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      fullName: map['fullName'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      city: map['city'],
    );
  }
}
