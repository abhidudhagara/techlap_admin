import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class OrdersChartPage extends StatefulWidget {
  const OrdersChartPage({super.key});

  @override
  State<OrdersChartPage> createState() => _OrdersChartPageState();
}

class _OrdersChartPageState extends State<OrdersChartPage> {
  List<FlSpot> spots = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOrderData();
  }

  Future<void> _fetchOrderData() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final ordersSnapshot = await firestore.collection('orders').get();

      // Group orders by date
      Map<String, int> ordersByDate = {};

      for (var doc in ordersSnapshot.docs) {
        // Check if the document has a timestamp field
        if (doc.data().containsKey('timestamp')) {
          final timestamp = doc['timestamp'] as Timestamp;
          final date = timestamp.toDate();
          final dateString = '${date.year}-${date.month}-${date.day}';

          ordersByDate[dateString] = (ordersByDate[dateString] ?? 0) + 1;
        } else if (doc.data().containsKey('createdAt')) {
          // Try alternative field name
          final timestamp = doc['createdAt'] as Timestamp;
          final date = timestamp.toDate();
          final dateString = '${date.year}-${date.month}-${date.day}';

          ordersByDate[dateString] = (ordersByDate[dateString] ?? 0) + 1;
        } else {
          // If no timestamp field exists, use document ID or current date
          final date = DateTime.now();
          final dateString = '${date.year}-${date.month}-${date.day}';

          ordersByDate[dateString] = (ordersByDate[dateString] ?? 0) + 1;
        }
      }

      // Convert to spots for the chart
      List<FlSpot> newSpots = [];
      int index = 0;

      ordersByDate.forEach((date, count) {
        newSpots.add(FlSpot(index.toDouble(), count.toDouble()));
        index++;
      });

      setState(() {
        spots = newSpots;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders Chart'),
        backgroundColor: Colors.red,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : spots.isEmpty
                  ? const Center(
                      child: Text('No order data available'),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Daily Orders Overview',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: true),
                                titlesData: const FlTitlesData(show: true),
                                borderData: FlBorderData(show: true),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: spots,
                                    isCurved: true,
                                    color: Colors.red,
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: true),
                                    belowBarData: BarAreaData(show: true),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
