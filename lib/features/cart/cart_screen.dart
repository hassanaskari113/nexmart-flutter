import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nexmart/core/constants/app_colors.dart';
import 'package:nexmart/core/constants/app_sizes.dart';
import 'package:nexmart/core/constants/app_strings.dart';
import 'package:nexmart/models/cart_item_model.dart';
import 'package:nexmart/providers/cart_provider.dart';
import 'package:nexmart/services/product_service.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  Widget _buildCartItem(BuildContext context, CartItemModel item, CartNotifier cartNotifier, formatter) {
    final isMaxQuantity = item.quantity >= item.product.stock;

    return Dismissible(
      key: ValueKey(item.product.productId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        cartNotifier.removeItem(item.product.productId);
      },
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.sm),
        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: AppSizes.lg),
        child: Icon(Icons.delete_outline_rounded, color: AppColors.white, size: AppSizes.iconLg),
      ),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.sm),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: CachedNetworkImage(
                  imageUrl: item.product.imageUrl,
                  height: AppSizes.cartImageSize,
                  width: AppSizes.cartImageSize,
                  fit: BoxFit.cover,
                  placeholder: (context, url) {
                    return Container(color: AppColors.shimmer, height: AppSizes.cartImageSize);
                  },
                  errorWidget: (context, url, error) {
                    return Container(
                      color: AppColors.shimmer,
                      height: AppSizes.cartImageSize,
                      child: Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary),
                    );
                  },
                ),
              ),

              SizedBox(width: AppSizes.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSizes.xs),
                    Text(
                      formatter.format(item.product.price),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.add_circle_outline_rounded),
                    color: isMaxQuantity ? AppColors.textSecondary : AppColors.primary,
                    onPressed: () {
                      if (isMaxQuantity) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Max stock reached'), duration: Duration(seconds: 1)));
                      } else {
                        cartNotifier.increaseQuantity(item.product.productId);
                      }
                    },
                  ),

                  Text(
                    item.quantity.toString(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {
                      cartNotifier.decreaseQuantity(item.product.productId);
                    },
                    icon: Icon(Icons.remove_circle_outline_rounded, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: AppColors.white),
        title: Text(
          AppStrings.cart,
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          cart.isEmpty
              ? Container()
              : TextButton(
                  onPressed: () {
                    cartNotifier.clearCart();
                  },
                  child: Text(
                    'Clear All',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.white),
                  ),
                ),
        ],
      ),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: AppSizes.iconLg * 2,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  SizedBox(height: AppSizes.md),
                  Text(
                    AppStrings.emptyCart,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: AppSizes.xs),
                  Text(
                    AppStrings.emptyCartSubtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: AppSizes.lg),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(onPressed: () => context.go('/home'), child: Text('Browse Products')),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // SCROLLABLE LIST
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return _buildCartItem(context, item, cartNotifier, formatter);
                    },
                  ),
                ),

                // BOTTOM TOTAL SECTION
                Container(
                  padding: EdgeInsets.all(AppSizes.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, -4))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.total,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            formatter.format(cartNotifier.totalPrice),
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSizes.md),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            for (final item in cart) {
                              final product = await ProductService().getProductById(item.product.productId);
                              if (item.quantity > product.stock) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${product.name} only has ${product.stock} left in stock')),
                                  );
                                }

                                return;
                              }
                            }
                            if (context.mounted) {
                              context.push('checkout');
                            }
                          },
                          child: Text(AppStrings.proceedToCheckout),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
