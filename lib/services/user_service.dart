import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexmart/models/user_model.dart';

class UserService {
  final _fireStore = FirebaseFirestore.instance;

  Stream<UserModel?> watchUserById(String userId) {
    return _fireStore.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return UserModel.fromMap(doc.data()!);
    });
  }

  Future<void> updateUserProfile(
    String userId, {
    required String name,
    required String phone,
    required String address,
  }) async {
    await _fireStore.collection('users').doc(userId).update({'name': name, 'phone': phone, 'address': address});
  }
}
