import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexmart/core/constants/app_colors.dart';
import 'package:nexmart/core/constants/app_sizes.dart';
import 'package:nexmart/core/constants/app_strings.dart';
import 'package:nexmart/providers/cart_provider.dart';
import 'package:nexmart/providers/product_provider.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productByIdProvider(widget.productId));
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return productAsync.when(
      data: (product) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                iconTheme: IconThemeData(color: Colors.transparent),
                expandedHeight: 350,
                pinned: true,
                backgroundColor: AppColors.shimmer,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'product-image-${product.productId}',
                    child: CachedNetworkImage(
                      fadeInDuration: Duration(milliseconds: 150),
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SECTION 1 - name and price row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            formatter.format(product.price),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSizes.md),
                      // SECTION 2 - rating and stock row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: AppColors.star, size: AppSizes.iconSm),
                              SizedBox(width: AppSizes.xs),
                              Text(product.rating.toString(), style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.xs),
                            decoration: BoxDecoration(
                              color: product.stock > 0
                                  ? AppColors.success.withValues(alpha: 0.15)
                                  : AppColors.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
                            ),
                            child: Text(
                              product.stock > 0 ? AppStrings.inStock : AppStrings.outOfStock,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,

                                color: product.stock > 0 ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSizes.lg),

                      // SECTION 3 - description
                      Text(
                        "Description",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: AppSizes.sm),
                      Text(
                        product.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                      SizedBox(height: AppSizes.xl),
                      // SECTION 4 - add to cart button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: product.stock == 0
                              ? null
                              : () {
                                  ref.read(cartProvider.notifier).addItem(product);
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(SnackBar(content: Text('${product.name} added to cart')));
                                },
                          child: Text(product.stock == 0 ? 'Out of Stock' : AppStrings.addToCart),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      error: (error, stack) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: SizedBox(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: AppSizes.iconLg),
                    SizedBox(height: AppSizes.sm),
                    Text(AppStrings.somethingWentWrong, style: Theme.of(context).textTheme.bodyMedium),
                    SizedBox(height: AppSizes.sm),
                    ElevatedButton(onPressed: () => ref.refresh(productsProvider), child: Text(AppStrings.tryAgain)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          ),
        ),
      ),
    );
  }
}
