import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexmart/models/order_model.dart';

class OrderService {
  final _fireStore = FirebaseFirestore.instance;

  Future<void> placeOrder(OrderModel order) async {
    final doc = _fireStore.collection('orders').doc(order.orderId);
    await doc.set(order.toMap());
  }

  Stream<List<OrderModel>> watchUserOrders(String userId) {
    return _fireStore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return OrderModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  Stream<OrderModel> watchOrderById(String orderId) {
    return _fireStore.collection('orders').doc(orderId).snapshots().map((doc) {
      return OrderModel.fromMap(doc.data()!, doc.id);
    });
  }

  Stream<List<OrderModel>> watchAllOrders() {
    return _fireStore.collection('orders').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _fireStore.collection('orders').doc(orderId).update({'status': newStatus});
  }
}
