import 'package:flutter/material.dart';
import '../services/firestore_service.dart'; // For password hashing

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  String _userName = '';
  String _userEmail = '';
  String _userRole = 'user';  // Default role as 'user'
  String _userStatus = 'active'; // Default status as 'active'
  String _password = '';  // Password for the user

  final FirestoreService _firestoreService = FirestoreService();

  void _saveUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Hash the password before saving to Firestore
      // For demonstration, we'll store it as plain text. In production, make sure to hash the password
      await _firestoreService.addUser({
        'name': _userName,
        'email': _userEmail,
        'role': _userRole,
        'status': _userStatus,
        'password': _password, // Store hashed password in real applications
      });
      
      Navigator.pop(context);  // Go back after adding user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'User Name'),
                validator: (value) => value!.isEmpty ? 'Enter user name' : null,
                onSaved: (value) => _userName = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'User Email'),
                validator: (value) {
                  if (value!.isEmpty) return 'Enter user email';
                  return null;
                },
                onSaved: (value) => _userEmail = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter user password';
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'User Role'),
                value: _userRole,
                items: ['admin', 'user'].map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (value) => setState(() => _userRole = value!),
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'User Status'),
                value: _userStatus,
                items: ['active', 'inactive'].map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (value) => setState(() => _userStatus = value!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUser,
                child: const Text('Add User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
