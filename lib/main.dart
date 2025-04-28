import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:techlap_admin/Page/ManageBrands.dart';
import 'package:techlap_admin/Page/ManageCategories.dart';
import 'package:techlap_admin/Page/ManageOrders.dart';
import 'package:techlap_admin/Page/ManageProducts.dart';
import 'package:techlap_admin/Page/ManageUsers.dart';
import 'package:techlap_admin/Page/OrdersChartPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TechLap Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    // Fetch data from Firebase Firestore (mocked here for now)
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var ordersSnapshot = await firestore.collection('orders').get();
    var productsSnapshot = await firestore.collection('products').get();
    var usersSnapshot = await firestore.collection('users').get();

    // Simulating calculation (total count)
    return {
      'totalOrders': ordersSnapshot.size,
      'totalProducts': productsSnapshot.size,
      'totalUsers': usersSnapshot.size,
      'revenue': '\$15,000', // Placeholder for real revenue calculation
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red,
      ),
      drawer: const AdminDrawer(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchDashboardData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          var data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                DashboardCard(
                  title: 'Total Orders',
                  count: data['totalOrders'].toString(),
                  color: Colors.blue,
                ),
                DashboardCard(
                  title: 'Total Products',
                  count: data['totalProducts'].toString(),
                  color: Colors.green,
                ),
                DashboardCard(
                  title: 'Total Users',
                  count: data['totalUsers'].toString(),
                  color: Colors.orange,
                ),
                DashboardCard(
                  title: 'Revenue',
                  count: data['revenue'],
                  color: Colors.purple,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;

  const DashboardCard({
    super.key,
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == 'Total Orders') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrdersChartPage()),
          );
        }
      },
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.red,
            ),
            child: Text(
              'Admin Panel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboard()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Products'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageProducts()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Orders'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageOrders()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Users'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageUsers()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageCategories()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.branding_watermark),
            title: const Text('Brands'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageBrands()),
              );
            },
          ),
        ],
      ),
    );
  }
}
