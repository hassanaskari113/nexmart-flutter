import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexmart/models/order_model.dart';
import 'package:nexmart/providers/auth_provider.dart';
import 'package:nexmart/services/order_service.dart';

final orderProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value([]);
  }
  return OrderService().watchUserOrders(user.uid);
});

final orderByIdProvider = StreamProvider.family<OrderModel, String>((ref, orderId) {
  return OrderService().watchOrderById(orderId);
});

final allOrderProvider = StreamProvider<List<OrderModel>>((ref) {
  return OrderService().watchAllOrders();
});
