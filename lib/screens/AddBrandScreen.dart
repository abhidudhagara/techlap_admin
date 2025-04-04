import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddBrandScreen extends StatefulWidget {
  const AddBrandScreen({super.key});

  @override
  _AddBrandScreenState createState() => _AddBrandScreenState();
}

class _AddBrandScreenState extends State<AddBrandScreen> {
  final TextEditingController _brandController = TextEditingController();

  Future<void> _addBrand() async {
    if (_brandController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('brands').add({
        'name': _brandController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _brandController.clear();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Brand'),
      backgroundColor: Colors.red,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: 'Brand Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addBrand,
              child: const Text('Add Brand'),
            ),
          ],
        ),
      ),
    );
  }
}
