import 'package:flutter/material.dart';
import '../services/firestore_service.dart'; // For password hashing

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  String _userName = '';
  String _userEmail = '';
  String _userRole = 'user'; // Default role
  String _userStatus = 'active'; // Default status
  String _password = '';

  final FirestoreService _firestoreService = FirestoreService();

  void _saveUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await _firestoreService.addUser({
        'name': _userName,
        'email': _userEmail,
        'role': _userRole,
        'status': _userStatus,
        'password': _password,
      });

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Light background
      appBar: AppBar(
        title: const Text('Add User'),
        backgroundColor: Colors.red,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 500), // Center card on large screens too
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter User Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // User Name
                  _buildTextField(
                    label: 'User Name',
                    onSaved: (value) => _userName = value!,
                    validator: (value) => value!.isEmpty ? 'Enter user name' : null,
                  ),
                  const SizedBox(height: 16),

                  // User Email
                  _buildTextField(
                    label: 'User Email',
                    onSaved: (value) => _userEmail = value!,
                    validator: (value) => value!.isEmpty ? 'Enter user email' : null,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  _buildTextField(
                    label: 'Password',
                    obscureText: true,
                    onSaved: (value) => _password = value!,
                    validator: (value) => value!.isEmpty ? 'Enter password' : null,
                  ),
                  const SizedBox(height: 16),

                  // User Role
                  _buildDropdownField(
                    label: 'User Role',
                    value: _userRole,
                    items: ['admin', 'user'],
                    onChanged: (value) => setState(() => _userRole = value!),
                  ),
                  const SizedBox(height: 16),

                  // User Status
                  _buildDropdownField(
                    label: 'User Status',
                    value: _userStatus,
                    items: ['active', 'inactive'],
                    onChanged: (value) => setState(() => _userStatus = value!),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save User',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build Text Field
  Widget _buildTextField({
    required String label,
    bool obscureText = false,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      decoration: _inputDecoration(label),
      obscureText: obscureText,
      onSaved: onSaved,
      validator: validator,
    );
  }

  // Build Dropdown Field
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: _inputDecoration(label),
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item.toUpperCase()),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // Common Decoration
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
