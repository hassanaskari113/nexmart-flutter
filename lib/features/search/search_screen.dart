import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexmart/core/constants/app_colors.dart';
import 'package:nexmart/core/constants/app_sizes.dart';
import 'package:nexmart/core/constants/app_strings.dart';
import 'package:nexmart/providers/product_provider.dart';
import 'package:nexmart/shared/widgets/product_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final products = ref.watch(filteredProductsProvider);
    final categories = ['All', 'Electronics', 'Clothing', 'Shoes', 'Accessories'];
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(searchQueryProvider.notifier).state = '';
          ref.read(selectedCategoryProvider.notifier).state = '';
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          toolbarHeight: 80,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          backgroundColor: AppColors.primary,
          leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.white, size: AppSizes.iconMd),
          ),
          title: Container(
            height: AppSizes.inputHeight - 10,
            padding: EdgeInsets.symmetric(horizontal: AppSizes.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              color: Colors.white.withValues(alpha: 0.15),
            ),
            alignment: Alignment.center,
            child: TextField(
              cursorColor: AppColors.white,
              controller: searchController,
              autofocus: false,
              style: TextStyle(color: AppColors.white, fontSize: AppSizes.fontMd),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: Colors.transparent,
                hintText: AppStrings.searchHint,
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: AppSizes.fontLg),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              color: AppColors.surface,
              padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: Row(
                  children: categories.map((category) {
                    final isActive = category == 'All' ? selectedCategory.isEmpty : selectedCategory == category;
                    return GestureDetector(
                      onTap: () {
                        if (category == 'All') {
                          ref.read(selectedCategoryProvider.notifier).state = '';
                        } else {
                          ref.read(selectedCategoryProvider.notifier).state = category;
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: AppSizes.sm),
                        padding: EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.xs + 2),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.secondary : Colors.transparent,
                          border: Border.all(
                            color: isActive ? AppColors.secondary : AppColors.textSecondary,
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
                        ),
                        child: Text(
                          category,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isActive ? AppColors.white : AppColors.textSecondary,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Divider(height: 1, color: AppColors.divider),
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: AppSizes.iconLg * 2,
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                          SizedBox(height: AppSizes.md),
                          Text(
                            AppStrings.noProductsFound,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
                          ),
                          SizedBox(height: AppSizes.xs),
                          Text(
                            'Try a different keyword or category',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.lg),
                      child: GridView.builder(
                        padding: EdgeInsets.only(top: AppSizes.md, bottom: AppSizes.lg),
                        physics: BouncingScrollPhysics(),
                        itemCount: products.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSizes.md,
                          mainAxisSpacing: AppSizes.md,
                          childAspectRatio: AppSizes.productCardWidth / AppSizes.productCardHeight,
                        ),
                        itemBuilder: (context, index) {
                          return ProductCard(product: products[index]);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
