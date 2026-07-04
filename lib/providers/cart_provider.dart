import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nexmart/models/product_model.dart';
import 'package:nexmart/models/cart_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartNotifier extends StateNotifier<List<CartItemModel>> {
  CartNotifier() : super([]) {
    _loadCartFromStorage();
  }

  static const String _storageKey = 'cart_items';

  void addItem(ProductModel product) {
    if (state.any((item) {
      return item.product.productId == product.productId;
    })) {
      state = state.map((item) {
        if (item.product.productId == product.productId) {
          item.quantity++;
          return item;
        }
        return item;
      }).toList();
    } else {
      state = [...state, CartItemModel(product: product, quantity: 1)];
    }
    _saveCartToStorage();
  }

  void removeItem(String productId) {
    state = state.where((item) {
      return item.product.productId != productId;
    }).toList();
    _saveCartToStorage();
  }

  void increaseQuantity(String productId) {
    final currentItem = state.firstWhere((item) => item.product.productId == productId);

    if (currentItem.quantity >= currentItem.product.stock) {
      return; // already at max, do nothing
    }
    state = state.map((item) {
      if (item.product.productId == productId) {
        item.quantity++;
        return item;
      }
      return item;
    }).toList();
    _saveCartToStorage();
  }

  void decreaseQuantity(String productId) {
    state = state.map((item) {
      if (item.product.productId == productId) {
        item.quantity--;
        return item;
      }
      return item;
    }).toList();
    state = state.where((item) {
      return item.quantity > 0;
    }).toList();
    _saveCartToStorage();
  }

  void clearCart() {
    state = [];
    _saveCartToStorage();
  }

  int get totalItems {
    return state.fold(0, (sum, item) {
      return sum + item.quantity.toInt();
    });
  }

  double get totalPrice {
    return state.fold(0, (sum, item) {
      return sum + item.totalPrice;
    });
  }

  Future<void> _saveCartToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final cartAsMap = state.map((cartItems) {
      return {'product': cartItems.product.toJson(), 'quantity': cartItems.quantity};
    }).toList();
    final jsonString = jsonEncode(cartAsMap);
    await prefs.setString(_storageKey, jsonString);
  }

  Future<void> _loadCartFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) {
      return;
    }
    final decode = jsonDecode(jsonString) as List;
    final restoredCart = decode.map((item) {
      final map = item as Map<String, dynamic>;
      return CartItemModel(product: ProductModel.fromJson(map['product']), quantity: map['quantity']);
    }).toList();
    state = restoredCart;
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItemModel>>((ref) {
  return CartNotifier();
});
