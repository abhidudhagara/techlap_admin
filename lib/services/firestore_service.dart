import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isAdmin() async {
    User? user = _auth.currentUser;
    if (user == null) return false;

    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();

    return userDoc.exists && userDoc['role'] == 'admin';
  }
}

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Fetch Categories
  Future<List<String>> getCategories() async {
    QuerySnapshot snapshot = await _db.collection('categories').get();
    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  // Fetch Brands
  Future<List<String>> getBrands() async {
    QuerySnapshot snapshot = await _db.collection('brands').get();
    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  // Add Product
  Future<void> addProduct({
    required String name,
    required double price,
    required String category,
    required String brand,
    required String imageUrl,
  }) async {
    await _db.collection('products').add({
      'name': name,
      'price': price,
      'category': category,
      'brand': brand,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Fetch product by ID
  Future<Map<String, dynamic>> getProductById(String productId) async {
    var doc = await _db.collection('products').doc(productId).get();
    return doc.data()!;
  }

  // Update product
  Future<void> updateProduct(String productId, Map<String, dynamic> updatedData) async {
    await _db.collection('products').doc(productId).update(updatedData);
  }

  // Get Products
  Stream<QuerySnapshot> getProducts() {
    return _db.collection('products').snapshots();
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  // Add new category ✅ (Admin check removed)
  Future<void> addCategory(String categoryName) async {
    await _db.collection('categories').add({
      'name': categoryName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream to get categories
  Stream<QuerySnapshot> getCategoriesStream() {
    return _db.collection('categories').orderBy('createdAt', descending: true).snapshots();
  }

  // Delete category ✅ (Admin check removed)
  Future<void> deleteCategory(String categoryId) async {
    await _db.collection('categories').doc(categoryId).delete();
  }

  // Update category name ✅ (Admin check removed)
  Future<void> updateCategory(String categoryId, String newName) async {
    await _db.collection('categories').doc(categoryId).update({
      'name': newName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Add Brand
  Future<void> addBrand(Map<String, dynamic> brandData) async {
    await _db.collection('brands').add(brandData);
  }

  // Get Brands as a Stream
  Stream<QuerySnapshot> getBrandsStream() {
    return _db.collection('brands').orderBy('createdAt', descending: true).snapshots();
  }

  // Delete Brand
  Future<void> deleteBrand(String brandId) async {
    await _db.collection('brands').doc(brandId).delete();
  }

  // Upload Image to Firebase Storage
  Future<String?> uploadImage(File image) async {
    try {
      String filePath = 'brand_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      TaskSnapshot taskSnapshot = await _storage.ref(filePath).putFile(image);
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  // Update Brand Information
  Future<void> updateBrand(String brandId, Map<String, dynamic> updatedData) async {
    await _db.collection('brands').doc(brandId).update(updatedData);
  }

  // Fetch products by brand
  Stream<QuerySnapshot> getProductsByBrand(String brand) {
    return _db.collection('products').where('brand', isEqualTo: brand).snapshots();
  }

  // Fetch all users
  Stream<QuerySnapshot> getUsers() {
    return _db.collection('users').snapshots();
  }

  // Add a new user
  Future<void> addUser(Map<String, dynamic> userData) async {
    await _db.collection('users').add(userData);
  }

  // Get user by ID
  Future<DocumentSnapshot> getUserById(String userId) async {
    return await _db.collection('users').doc(userId).get();
  }

  // Update user
  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    await _db.collection('users').doc(userId).update(userData);
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    await _db.collection('users').doc(userId).delete();
  }
}
