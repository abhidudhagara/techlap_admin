import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:techlap_admin/screens/AddBrandScreen.dart';

class ManageBrands extends StatefulWidget {
  const ManageBrands({super.key});

  @override
  _ManageBrandsState createState() => _ManageBrandsState();
}

class _ManageBrandsState extends State<ManageBrands> {
  Future<void> _deleteBrand(String id) async {
    await FirebaseFirestore.instance.collection('brands').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Brands'),
      backgroundColor: Colors.red,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('brands').orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No brands available.'));
                  }
                  var brands = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: brands.length,
                    itemBuilder: (context, index) {
                      var brand = brands[index];
                      return Card(
                        child: ListTile(
                          title: Text(brand['name']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteBrand(brand.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddBrandScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
