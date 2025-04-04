import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techlap_admin/services/firestore_service.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;

  const EditProductScreen({Key? key, required this.productId}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String _productName = '';
  String _productPrice = '';
  String? _selectedCategory;
  String? _selectedBrand;
  bool _isUploading = false;

  List<String> _categories = [];
  List<String> _brands = [];

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
    _loadProductData();
  }

  Future<void> _loadDropdownData() async {
    List<String> categories = await _firestoreService.getCategories();
    List<String> brands = await _firestoreService.getBrands();
    setState(() {
      _categories = categories;
      _brands = brands;
    });
  }

  Future<void> _loadProductData() async {
    var product = await _firestoreService.getProductById(widget.productId);
    setState(() {
      _productName = product['name'];
      _productPrice = product['price'].toString();
      _selectedCategory = product['category'];
      _selectedBrand = product['brand'];
    });
  }

  void _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      _formKey.currentState!.save();

      await _firestoreService.updateProduct(widget.productId, {
        'name': _productName,
        'price': double.parse(_productPrice),
        'category': _selectedCategory,
        'brand': _selectedBrand,
      });

      setState(() {
        _isUploading = false;
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _productName,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) => value!.isEmpty ? 'Enter product name' : null,
                onSaved: (value) => _productName = value!,
              ),
              TextFormField(
                initialValue: _productPrice,
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
              _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _updateProduct,
                      child: const Text('Update Product'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
