import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexmart/core/constants/app_colors.dart';
import 'package:nexmart/core/constants/app_sizes.dart';
import 'package:nexmart/core/constants/app_strings.dart';
import 'package:nexmart/providers/product_provider.dart';

class ManageProductsScreen extends ConsumerWidget {
  const ManageProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: AppColors.white),
        title: Text(
          'Manage Products',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return SizedBox(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, color: AppColors.textSecondary, size: AppSizes.iconLg),
                    SizedBox(height: AppSizes.sm),
                    Text(AppStrings.noProductsFound, style: Theme.of(context).textTheme.bodyMedium),
                    SizedBox(height: AppSizes.md),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () => context.go('/admin/add-product'),
                        child: Text('Add Products'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.sm),
                child: ListTile(
                  contentPadding: EdgeInsets.all(AppSizes.sm),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    child: CachedNetworkImage(
                      imageUrl: products[index].imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      fadeInDuration: Duration(milliseconds: 150),
                    ),
                  ),

                  title: Text(
                    products[index].name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '\$${products[index].price} • Stock: ${products[index].stock}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  onTap: () => context.push('/admin/edit-product/${products[index].productId}'),
                ),
              );
            },
          );
        },
        error: (error, stack) {
          return SizedBox(
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
          );
        },
        loading: () => SizedBox(
          height: 300,
          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ),
      ),
    );
  }
}
