import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: Colors.red, // Consistent with app theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Name Field
              TextFormField(
                initialValue: _productName,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                validator: (value) => value!.isEmpty ? 'Enter product name' : null,
                onSaved: (value) => _productName = value!,
              ),
              const SizedBox(height: 16),

              // Product Price Field
              TextFormField(
                initialValue: _productPrice,
                decoration: InputDecoration(
                  labelText: 'Price',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter price';
                  if (double.tryParse(value) == null) return 'Enter a valid price';
                  return null;
                },
                onSaved: (value) => _productPrice = value!,
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
              const SizedBox(height: 16),

              // Brand Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Brand',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                value: _selectedBrand,
                items: _brands.map((brand) {
                  return DropdownMenuItem(value: brand, child: Text(brand));
                }).toList(),
                onChanged: (value) => setState(() => _selectedBrand = value),
              ),
              const SizedBox(height: 24),

              // Update Button or Progress Indicator
              _isUploading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _updateProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Update Product',
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
