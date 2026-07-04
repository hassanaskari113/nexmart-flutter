import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  // fields
  final String uid;
  final String name;
  final String phone;
  final String address;
  final String email;
  final String photoUrl;
  final String role;
  final DateTime createdAt;

  // constructor
  const UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
    required this.photoUrl,
    required this.role,
    required this.createdAt,
  });

  // convert object to Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'address': address,
      'email': email,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // convert Map from Firestore back to UserModel object
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      email: map['email'],
      photoUrl: map['photoUrl'] ?? '',
      role: map['role'] ?? 'customer',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
