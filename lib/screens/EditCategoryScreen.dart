import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class EditCategoryScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const EditCategoryScreen({super.key, required this.categoryId, required this.categoryName});

  @override
  _EditCategoryScreenState createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _updatedCategoryName;
  bool _isUpdating = false;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _updatedCategoryName = widget.categoryName;
  }

  Future<void> _updateCategory() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUpdating = true;
      });

      _formKey.currentState!.save();

      try {
        await _firestoreService.updateCategory(widget.categoryId, _updatedCategoryName);
        setState(() {
          _isUpdating = false;
        });
        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _isUpdating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Category'),
        backgroundColor: Colors.red, // Keep it consistent with your app theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Edit Category Details',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Category Name Input Field
              TextFormField(
                initialValue: _updatedCategoryName,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                validator: (value) => value!.isEmpty ? 'Enter category name' : null,
                onSaved: (value) => _updatedCategoryName = value!,
              ),
              const SizedBox(height: 20),

              // Update Button or Progress Indicator
              _isUpdating
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _updateCategory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Update Category',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
