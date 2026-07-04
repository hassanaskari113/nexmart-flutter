import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nexmart/core/constants/app_colors.dart';
import 'package:nexmart/core/constants/app_sizes.dart';
import 'package:nexmart/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        onTap: () => context.push('/product/${product.productId}'),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Hero(
                tag: 'product-image-${product.productId}',
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.radiusLg),
                    topRight: Radius.circular(AppSizes.radiusLg),
                  ),
                  child: CachedNetworkImage(
                    fadeInDuration: Duration(milliseconds: 150),
                    imageUrl: product.imageUrl,
                    height: AppSizes.productCardHeight * 0.55,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) {
                      return Container(color: AppColors.shimmer, height: AppSizes.productCardHeight * 0.55);
                    },
                    errorWidget: (context, url, error) {
                      return Container(
                        color: AppColors.shimmer,
                        height: AppSizes.productCardHeight * 0.55,
                        child: Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary),
                      );
                    },
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSizes.xs),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatter.format(product.price),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary),
                          ),
                          SizedBox(height: AppSizes.xs),
                          Row(
                            children: [
                              Icon(Icons.star_rounded, color: AppColors.star, size: AppSizes.iconSm),
                              SizedBox(width: 2),
                              Text(product.rating.toString(), style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
