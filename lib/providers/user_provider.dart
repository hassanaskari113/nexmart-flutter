import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexmart/models/user_model.dart';
import 'package:nexmart/providers/auth_provider.dart';
import 'package:nexmart/services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

final userDataProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value(null);
  }
  return ref.watch(userServiceProvider).watchUserById(user.uid);
});

final isAdminProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(userDataProvider);
  return userAsync.value?.role == 'admin';
});
