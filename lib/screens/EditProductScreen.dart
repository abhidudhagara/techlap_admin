import 'package:flutter/material.dart';
import 'package:techlap_admin/services/firestore_service.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;

  const EditProductScreen({Key? key, required this.productId})
      : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String _productName = '';
  String _productPrice = '';
  String _productDescription = '';
  String? _selectedCategory;
  String? _selectedBrand;
  String _originalImageUrl = '';
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
    try {
      List<String> categories = await _firestoreService.getCategories();
      List<String> brands = await _firestoreService.getBrands();
      if (mounted) {
        setState(() {
          _categories = categories.toSet().toList();
          _brands = brands.toSet().toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dropdown data: $e')),
        );
      }
    }
  }

  Future<void> _loadProductData() async {
    try {
      var product = await _firestoreService.getProductById(widget.productId);
      if (mounted) {
        setState(() {
          _productName = product['name'];
          _productPrice = product['price'].toString();
          _productDescription = product['description'] ?? '';
          _selectedCategory = product['category'];
          _selectedBrand = product['brand'];
          _originalImageUrl = product['imageUrl'] ?? '';

          // Validate that the loaded values exist in the dropdowns
          if (!_categories.contains(_selectedCategory)) {
            _selectedCategory = _categories.isNotEmpty ? _categories[0] : null;
          }
          if (!_brands.contains(_selectedBrand)) {
            _selectedBrand = _brands.isNotEmpty ? _brands[0] : null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading product data: $e')),
        );
      }
    }
  }

  void _updateProduct() async {
    if (!mounted) return;

    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null || _selectedBrand == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select both category and brand')),
        );
        return;
      }

      if (!mounted) return;
      setState(() {
        _isUploading = true;
      });

      _formKey.currentState!.save();

      try {
        Map<String, dynamic> updateData = {
          'name': _productName,
          'price': double.parse(_productPrice),
          'category': _selectedCategory,
          'brand': _selectedBrand,
          'description': _productDescription,
          'imageUrl': _originalImageUrl, // Keep the original image URL
        };

        await _firestoreService.updateProduct(widget.productId, updateData);

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating product: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    super.dispose();
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
                validator: (value) =>
                    value!.isEmpty ? 'Enter product name' : null,
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
                  if (double.tryParse(value) == null)
                    return 'Enter a valid price';
                  return null;
                },
                onSaved: (value) => _productPrice = value!,
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                initialValue: _productDescription,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Enter product description' : null,
                onSaved: (value) => _productDescription = value!,
              ),
              const SizedBox(height: 16),

              // Image Preview
              if (_originalImageUrl.isNotEmpty)
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _originalImageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
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
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
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
                  return DropdownMenuItem<String>(
                    value: brand,
                    child: Text(brand),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedBrand = value);
                  }
                },
                validator: (value) =>
                    value == null ? 'Please select a brand' : null,
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
