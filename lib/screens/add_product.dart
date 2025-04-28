import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String _productName = '';
  String _productPrice = '';
  String? _selectedCategory;
  String? _selectedBrand;
  String _imageUrl = ''; // ✅ Accepts Image URL instead of File
  bool _isUploading = false;

  List<String> _categories = [];
  List<String> _brands = [];

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    List<String> categories = await _firestoreService.getCategories();
    List<String> brands = await _firestoreService.getBrands();
    setState(() {
      _categories = categories;
      _brands = brands;
    });
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      _formKey.currentState!.save();

      await _firestoreService.addProduct(
        name: _productName,
        price: double.parse(_productPrice),
        category: _selectedCategory!,
        brand: _selectedBrand!,
        imageUrl: _imageUrl, // ✅ Storing Image URL instead of File Upload
      );

      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) => value!.isEmpty ? 'Enter product name' : null,
                onSaved: (value) => _productName = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter price';
                  if (double.tryParse(value) == null) return 'Enter a valid price';
                  return null;
                },
                onSaved: (value) => _productPrice = value!,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Brand'),
                value: _selectedBrand,
                items: _brands.map((brand) {
                  return DropdownMenuItem(value: brand, child: Text(brand));
                }).toList(),
                onChanged: (value) => setState(() => _selectedBrand = value),
              ),
              const SizedBox(height: 20),

              // ✅ Image URL Input Field
              TextFormField(
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (value) => value!.isEmpty ? 'Enter image URL' : null,
                onSaved: (value) => _imageUrl = value!,
              ),

              const SizedBox(height: 20),
              _imageUrl.isNotEmpty
                  ? Image.network(_imageUrl, height: 100)
                  : const Icon(Icons.image, size: 50, color: Colors.grey),

              const SizedBox(height: 20),
              _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveProduct,
                      child: const Text('Add Product'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}