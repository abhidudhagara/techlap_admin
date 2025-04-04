import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class EditUserScreen extends StatefulWidget {
  final String userId;
  const EditUserScreen({super.key, required this.userId});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  String _userName = '';
  String _userEmail = '';
  String _userRole = 'user';
  String _userStatus = 'active';
  String _password = '';  // Password field

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    var user = await _firestoreService.getUserById(widget.userId);
    setState(() {
      _userName = user['name'];
      _userEmail = user['email'];
      _userRole = user['role'];
      _userStatus = user['status'];
    });
  }

  void _saveUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // If password is provided, include it in the update
      Map<String, dynamic> userData = {
        'name': _userName,
        'email': _userEmail,
        'role': _userRole,
        'status': _userStatus,
      };

      if (_password.isNotEmpty) {
        // Store the hashed password if provided
        userData['password'] = _password;
      }

      await _firestoreService.updateUser(widget.userId, userData);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _userName,
                decoration: const InputDecoration(labelText: 'User Name'),
                validator: (value) => value!.isEmpty ? 'Enter user name' : null,
                onSaved: (value) => _userName = value!,
              ),
              TextFormField(
                initialValue: _userEmail,
                decoration: const InputDecoration(labelText: 'User Email'),
                validator: (value) {
                  if (value!.isEmpty) return 'Enter user email';
                  return null;
                },
                onSaved: (value) => _userEmail = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password (Leave blank to keep unchanged)'),
                obscureText: true,
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
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
