import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageOrders extends StatelessWidget {
  const ManageOrders({super.key});

  void _editOrder(BuildContext context, String orderId, Map<String, dynamic> orderData) {
    final List<String> statuses = ['Pending', 'Processing', 'Confirmed', 'Shipped', 'Delivered', 'Cancelled'];

    String fetchedStatus = orderData['orderStatus'] ?? 'Pending';
    String currentStatus = statuses.contains(fetchedStatus) ? fetchedStatus : 'Pending';

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Order: $orderId'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Update Order Status:'),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: currentStatus,
                  isExpanded: true,
                  items: statuses.map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        currentStatus = newValue;
                      });
                    }
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('orders')
                    .doc(orderId)
                    .update({'orderStatus': currentStatus});

                Navigator.of(ctx).pop();

                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Order status updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.of(ctx).pop();
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Error updating order: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderDoc = orders[index];
              final orderId = orderDoc.id;
              final Map<String, dynamic> orderData = orderDoc.data() as Map<String, dynamic>;

              final customer = orderData['customer'] ?? {};
              final payment = orderData['payment'] ?? {};
              final product = orderData['product'] ?? {};

              final customerName = customer['name'] ?? 'Unknown Customer';
              final customerEmail = customer['email'] ?? 'No Email';
              final address = customer['address'] ?? 'No Address';
              final phone = customer['phone'] ?? 'No Phone';

              final orderDate = orderData['orderDate']?.toDate() ?? DateTime.now();
              final orderStatus = orderData['orderStatus'] ?? 'Unknown';

              final paymentMethod = payment['method'] ?? 'No Method';
              final paymentStatus = payment['status'] ?? 'No Status';

              final productName = product['name'] ?? 'Unnamed Product';
              final productPrice = product['price'] ?? 0.0;
              final productStatus = product['status'] ?? 'No Status';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.receipt_long, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('Order ID: $orderId',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editOrder(context, orderId, orderData),
                          ),
                        ],
                      ),
                      const Divider(),
                      Text('Customer: $customerName', style: const TextStyle(fontSize: 15)),
                      Text('Email: $customerEmail', style: const TextStyle(fontSize: 15)),
                      Text('Address: $address', style: const TextStyle(fontSize: 15)),
                      Text('Phone: $phone', style: const TextStyle(fontSize: 15)),
                      Text('Order Date: ${orderDate.toLocal()}'.split(' ')[0], style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 8),
                      Text(
                        'Order Status: $orderStatus',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: orderStatus == 'Delivered'
                              ? Colors.green
                              : orderStatus == 'Cancelled'
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Payment Method: $paymentMethod', style: const TextStyle(fontSize: 15)),
                      Text('Payment Status: $paymentStatus', style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 8),
                      const Text(
                        'Product:',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                      ),
                      const SizedBox(height: 4),
                      Text('Name: $productName', style: const TextStyle(fontSize: 15)),
                      Text('Price: ₹$productPrice', style: const TextStyle(fontSize: 15)),
                      Text('Product Status: $productStatus', style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}