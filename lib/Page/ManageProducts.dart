import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techlap_admin/screens/EditProductScreen.dart';
import 'package:techlap_admin/screens/add_product.dart';
import '../services/firestore_service.dart';

class ManageProducts extends StatefulWidget {
  const ManageProducts({super.key});

  @override
  _ManageProductsState createState() => _ManageProductsState();
}

class _ManageProductsState extends State<ManageProducts> {
  final FirestoreService _firestoreService = FirestoreService();

  void _deleteProduct(String productId) {
    _firestoreService.deleteProduct(productId);
  }

  void _editProduct(BuildContext context, String productId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProductScreen(productId: productId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Products')),
      body: Expanded(
        // Display all products
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getProducts(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            var products = snapshot.data!.docs;

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                var product = products[index];
                return ListTile(
                  title: Text(product['name']),
                  subtitle: Text(
                    'Price: \$${product['price']} | Category: ${product['category']} | Brand: ${product['brand']}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit product button
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editProduct(context, product.id),
                      ),
                      // Delete product button
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(product.id),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      // Floating button to add new product
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProductScreen()),
        ),
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }
}