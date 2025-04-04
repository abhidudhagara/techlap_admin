import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techlap_admin/screens/AddCategoryScreen.dart';
import 'package:techlap_admin/screens/EditCategoryScreen.dart';
import '../services/firestore_service.dart';

class ManageCategories extends StatefulWidget {
  const ManageCategories({super.key});

  @override
  _ManageCategoriesState createState() => _ManageCategoriesState();
}

class _ManageCategoriesState extends State<ManageCategories> {
  final FirestoreService _firestoreService = FirestoreService();

  void _deleteCategory(String categoryId) {
    _firestoreService.deleteCategory(categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: Colors.red,
      ),
      body: Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getCategoriesStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            var categories = snapshot.data!.docs;

            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                var category = categories[index];
                return ListTile(
                  title: Text(category['name']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditCategoryScreen(
                              categoryId: category.id,
                              categoryName: category['name'],
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCategory(category.id),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
        ),
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }
}