import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techlap_admin/screens/AddUserScreen.dart';
import 'package:techlap_admin/screens/EditUserScreen.dart';
import '../services/firestore_service.dart';

class ManageUsers extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  ManageUsers({super.key});

  void _deleteUser(String userId) {
    _firestoreService.deleteUser(userId);
  }

  void _editUser(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditUserScreen(userId: userId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          var users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              var userData = user.data() as Map<String, dynamic>;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(
                    userData['name'] ?? 'No Name',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${userData['email'] ?? 'No Email'}'),
                        const SizedBox(height: 4),
                        Text('Role: ${userData['role'] ?? 'No Role'}'),
                        const SizedBox(height: 4),
                        Text('Status: ${userData['status'] ?? 'No Status'}'),
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editUser(context, user.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(user.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddUserScreen()),
        ),
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }
}