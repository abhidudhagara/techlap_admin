import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/firestore_service.dart';

class EditBrandScreen extends StatefulWidget {
  final String brandId;
  final String currentName;
  final String currentImageUrl;

  const EditBrandScreen({
    super.key,
    required this.brandId,
    required this.currentName,
    required this.currentImageUrl,
  });

  @override
  _EditBrandScreenState createState() => _EditBrandScreenState();
}

class _EditBrandScreenState extends State<EditBrandScreen> {
  final _formKey = GlobalKey<FormState>();
  String _brandName = '';
  File? _selectedImage;
  bool _isUploading = false;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _brandName = widget.currentName;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      _formKey.currentState!.save();

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _firestoreService.uploadImage(_selectedImage!);
      } else {
        imageUrl = widget.currentImageUrl; // Keep the current image if not updated
      }

      await _firestoreService.updateBrand(widget.brandId, {
        'name': _brandName,
        'imageUrl': imageUrl,
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
      appBar: AppBar(title: const Text('Edit Brand')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _brandName,
                decoration: const InputDecoration(labelText: 'Brand Name'),
                validator: (value) => value!.isEmpty ? 'Enter brand name' : null,
                onSaved: (value) => _brandName = value!,
              ),
              const SizedBox(height: 20),
              _selectedImage != null
                  ? Image.file(_selectedImage!, height: 100)
                  : widget.currentImageUrl.isNotEmpty
                      ? Image.network(widget.currentImageUrl, height: 100)
                      : const Icon(Icons.image, size: 50, color: Colors.grey),
              TextButton.icon(
                icon: const Icon(Icons.upload),
                label: const Text('Upload Image'),
                onPressed: _pickImage,
              ),
              const SizedBox(height: 20),
              _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveChanges,
                      child: const Text('Save Changes'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
