import 'package:flutter/material.dart';

class ManageOrders extends StatelessWidget {
  const ManageOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        itemCount: 5, // Static number of orders
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Order #$index'), // ✅ Removed const
            subtitle: const Text('Status: Pending'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Edit order logic here
              },
            ),
          );
        },
      ),
    );
  }
}
