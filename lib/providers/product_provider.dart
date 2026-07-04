import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nexmart/models/product_model.dart';
import 'package:nexmart/services/product_service.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

final productsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final productService = ref.watch(productServiceProvider);
  final products = await productService.getProducts();
  return products;
});

final productByIdProvider = FutureProvider.family<ProductModel, String>((ref, productId) async {
  final productService = ref.watch(productServiceProvider);
  final product = await productService.getProductById(productId);
  return product;
});

final selectedCategoryProvider = StateProvider<String>((ref) {
  return '';
});

final searchQueryProvider = StateProvider<String>((ref) {
  return '';
});

final filteredProductsProvider = Provider<List<ProductModel>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  return productsAsync.when(
    data: (products) {
      return products.where((product) {
        final matchesSearch = searchQuery.isEmpty || product.name.toLowerCase().contains(searchQuery.toLowerCase());
        final matchesCategory = selectedCategory.isEmpty || product.category == selectedCategory;
        return matchesCategory && matchesSearch;
      }).toList();
    },
    error: (error, stack) => [],
    loading: () => [],
  );
});
