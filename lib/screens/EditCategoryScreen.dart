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
      appBar: AppBar(title: const Text('Edit Category')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _updatedCategoryName,
                decoration: const InputDecoration(labelText: 'Category Name'),
                validator: (value) => value!.isEmpty ? 'Enter category name' : null,
                onSaved: (value) => _updatedCategoryName = value!,
              ),
              const SizedBox(height: 20),
              _isUpdating
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _updateCategory,
                      child: const Text('Update Category'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
