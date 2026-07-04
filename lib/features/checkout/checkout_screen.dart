import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nexmart/core/constants/app_colors.dart';
import 'package:nexmart/core/constants/app_sizes.dart';
import 'package:nexmart/core/constants/app_strings.dart';
import 'package:nexmart/models/cart_item_model.dart';
import 'package:nexmart/providers/cart_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexmart/models/order_model.dart';
import 'package:nexmart/services/order_service.dart';
import 'package:nexmart/services/product_service.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  late TextEditingController fullNameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    cityController = TextEditingController();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    super.dispose();
  }

  Widget _buildOrderSummary(BuildContext context, List<CartItemModel> cart, formatter, totalAmount) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, -4))],
      ),
      padding: EdgeInsets.all(AppSizes.lg),
      child: Column(
        children: [
          ...cart.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppSizes.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantity}x ${item.product.name}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    formatter.format(item.totalPrice),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }),
          Divider(color: AppColors.divider, height: AppSizes.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.total,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                formatter.format(totalAmount),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitOrder(List<CartItemModel> cart, double totalAmount) async {
    try {
      setState(() {
        isLoading = true;
      });

      final userId = FirebaseAuth.instance.currentUser!.uid;
      final orderId = FirebaseFirestore.instance.collection('orders').doc().id;

      final order = OrderModel(
        orderId: orderId,
        userId: userId,
        items: cart,
        totalAmount: totalAmount,
        status: 'pending',
        createdAt: DateTime.now(),
        fullName: fullNameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        address: addressController.text.trim(),
        city: cityController.text.trim(),
      );

      await OrderService().placeOrder(order);
      if (!mounted) {
        return;
      }
      for (final item in cart) {
        await ProductService().decrementStock(item.product.productId, item.quantity);
      }
      if (!mounted) {
        return;
      }
      ref.read(cartProvider.notifier).clearCart();
      context.go('/home');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.orderSuccess)));
    } catch (e) {
      debugPrint('Error placing order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.somethingWentWrong)));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _placeOrder(List<CartItemModel> cart, double totalAmount, NumberFormat formatter) async {
    if (fullNameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields!')));
      return;
    }

    for (final item in cart) {
      final product = await ProductService().getProductById(item.product.productId);
      if (item.quantity > product.stock) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${product.name} only has ${product.stock} left in stock')));
        }

        return;
      }
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Confirm Order'),
            content: Text('Place this order for ${formatter.format(totalAmount)}?'),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  context.pop();
                  await _submitOrder(cart, totalAmount);
                },
                child: Text(
                  'Confirm',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final totalAmount = cartNotifier.totalPrice;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: AppColors.white),
        title: Text(
          AppStrings.checkout,
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DELIVERY ADDRESS SECTION HEADER
                  Text(
                    AppStrings.deliveryAddress,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: AppSizes.md),

                  // FORM FIELDS
                  TextField(
                    controller: fullNameController,
                    decoration: InputDecoration(
                      labelText: AppStrings.fullName,
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),

                  SizedBox(height: AppSizes.md),

                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: AppStrings.phoneNumber,
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),

                  SizedBox(height: AppSizes.md),

                  TextField(
                    controller: addressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: AppStrings.address,
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),

                  SizedBox(height: AppSizes.md),

                  TextField(
                    controller: cityController,
                    decoration: InputDecoration(
                      labelText: AppStrings.city,
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                  ),

                  SizedBox(height: AppSizes.xl),

                  // ORDER SUMMARY SECTION HEADER
                  Text(
                    AppStrings.orderSummary,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: AppSizes.md),

                  // ORDER SUMMARY CARD
                  _buildOrderSummary(context, cart, formatter, totalAmount),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, -4))],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _placeOrder(cart, totalAmount, formatter),
                child: isLoading ? CircularProgressIndicator(color: AppColors.white) : Text(AppStrings.placeOrder),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
