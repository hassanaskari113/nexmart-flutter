import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexmart/models/product_model.dart';

class ProductService {
  final _fireStore = FirebaseFirestore.instance;

  Future<List<ProductModel>> getProducts() async {
    List<ProductModel> products = [];
    final collection = _fireStore.collection('products');
    final querySnapShot = await collection.get();
    final docs = querySnapShot.docs;
    products = docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
    return products;
  }

  Future<ProductModel> getProductById(String id) async {
    final ProductModel product;
    final doc = await _fireStore.collection('products').doc(id).get();
    if (!doc.exists) {
      throw Exception('Product not found');
    }
    product = ProductModel.fromMap(doc.data()!, doc.id);
    return product;
  }

  Future<void> addProduct(ProductModel product) async {
    await _fireStore.collection('products').doc(product.productId).set(product.toMap());
  }

  Future<void> updateProduct(ProductModel product) async {
    await _fireStore.collection('products').doc(product.productId).update(product.toMap());
  }

  Future<void> decrementStock(String productId, int quantity) async {
    final docRef = _fireStore.collection('products').doc(productId);
    await _fireStore.runTransaction((transaction) async {
      final snapShot = await transaction.get(docRef);
      final currStock = (snapShot.data()?['stock'] as num).toInt();
      final newStock = currStock - quantity;
      transaction.update(docRef, {'stock': newStock < 0 ? 0 : newStock});
    });
  }
}
