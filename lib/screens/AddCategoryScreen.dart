import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  String _categoryName = '';
  bool _isUploading = false;
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });
      _formKey.currentState!.save();

      try {
        await _firestoreService.addCategory(_categoryName);
        setState(() {
          _isUploading = false;
        });
        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _isUploading = false;
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
      appBar: AppBar(title: const Text('Add Category'),
      backgroundColor: Colors.red,),
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Category Name'),
                validator: (value) => value!.isEmpty ? 'Enter category name' : null,
                onSaved: (value) => _categoryName = value!,
              ),
              const SizedBox(height: 20),
              _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveCategory,
                      child: const Text('Add Category'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
