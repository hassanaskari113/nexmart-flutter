import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nexmart/core/constants/app_colors.dart';
import 'package:nexmart/core/constants/app_sizes.dart';
import 'package:nexmart/core/constants/app_strings.dart';
import 'package:nexmart/models/product_model.dart';
import 'package:nexmart/providers/product_provider.dart';
import 'package:nexmart/services/product_service.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  final String? productId;
  const AddProductScreen({super.key, this.productId});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  bool get isEditMode => widget.productId != null;
  ProductModel? existingProduct;

  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController imageUrlController;
  late TextEditingController stockController;

  String selectedCategory = 'Electronics';
  bool isLoading = false;
  String? previewUrl;

  final List<String> categories = ['Electronics', 'Clothing', 'Shoes', 'Accessories'];

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final price = double.parse(priceController.text.trim());
    final stock = int.parse(stockController.text.trim());

    try {
      setState(() {
        isLoading = true;
      });

      final productId = isEditMode ? widget.productId! : FirebaseFirestore.instance.collection('products').doc().id;

      final product = ProductModel(
        productId: productId,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        price: price,
        imageUrl: imageUrlController.text.trim(),
        category: selectedCategory,
        stock: stock,
        rating: isEditMode ? existingProduct!.rating : 0.0,
        createdAt: isEditMode ? existingProduct!.createdAt : DateTime.now(),
      );

      if (isEditMode) {
        await ProductService().updateProduct(product);
      } else {
        await ProductService().addProduct(product);
      }

      ref.invalidate(productsProvider);

      if (!mounted) {
        return;
      }

      context.pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Product ${isEditMode ? 'updated' : 'added'} successfully')));
    } catch (e) {
      debugPrint('Error adding product: $e');
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

  Future<void> _loadExistingProduct() async {
    final product = await ProductService().getProductById(widget.productId!);
    if (!mounted) return;
    setState(() {
      existingProduct = product;
      nameController.text = product.name;
      descriptionController.text = product.description;
      priceController.text = product.price.toString();
      stockController.text = product.stock.toString();
      imageUrlController.text = product.imageUrl;
      selectedCategory = product.category;
    });
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    priceController = TextEditingController();
    imageUrlController = TextEditingController();
    stockController = TextEditingController();

    if (isEditMode) {
      _loadExistingProduct();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    imageUrlController.dispose();
    stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: AppColors.white),
        title: Text(
          isEditMode ? 'Edit Product' : 'Add Product',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Product Name', prefixIcon: Icon(Icons.shopping_bag_outlined)),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a product name';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSizes.md),

              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description_outlined)),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSizes.md),

              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Price', prefixIcon: Icon(Icons.attach_money)),
                validator: (value) {
                  final price = double.tryParse(value?.trim() ?? '');
                  if (price == null) {
                    return 'Enter a valid price';
                  }
                  if (price <= 0) {
                    return 'Price must be greater than 0';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSizes.md),

              TextFormField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Stock Quantity', prefixIcon: Icon(Icons.inventory_2_outlined)),
                validator: (value) {
                  final stock = int.tryParse(value?.trim() ?? '');
                  if (stock == null) {
                    return 'Enter a valid stock quantity';
                  }
                  if (stock < 0) {
                    return 'Stock cannot be negative';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSizes.md),

              TextFormField(
                controller: imageUrlController,
                decoration: InputDecoration(labelText: 'Image URL', prefixIcon: Icon(Icons.image_outlined)),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Enter an image URL';
                  }
                  final uri = Uri.tryParse(text);
                  if (uri == null || !(uri.isScheme('HTTP') || uri.isScheme('HTTPS'))) {
                    return 'Enter a valid URL';
                  }
                  return null;
                },
                onChanged: (value) {
                  final trimmed = value.trim();
                  final uri = Uri.tryParse(trimmed);
                  final looksValid = uri != null && (uri.isScheme('HTTP') || uri.isScheme('HTTPS'));
                  setState(() {
                    previewUrl = looksValid ? trimmed : null;
                  });
                },
              ),

              // IMAGE PREVIEW
              if (previewUrl != null) ...[
                SizedBox(height: AppSizes.md),
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: previewUrl!,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      errorWidget: (context, url, error) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image_outlined, color: AppColors.white),
                            SizedBox(height: 4),
                            Text('Could not load image', style: TextStyle(fontSize: 12, color: AppColors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              SizedBox(height: AppSizes.md),

              // CATEGORY DROPDOWN
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_outlined)),
                items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (value) => setState(() => selectedCategory = value!),
              ),

              SizedBox(height: AppSizes.xl),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveProduct,
                  child: isLoading
                      ? CircularProgressIndicator(color: AppColors.white)
                      : Text(isEditMode ? 'Save Changes' : 'Add Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
