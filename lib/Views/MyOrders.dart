import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled/Controllers/databaseHelper.dart';
import 'package:firebase_core/firebase_core.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrders createState() => _MyOrders();
}

class _MyOrders extends State<MyOrders> {
  final DBHelper dbHelper = DBHelper();
  String selectedStatus = "Delivered";

  void updateSelectedStatus(String status) {
setState(() {
selectedStatus = status;
});
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop()
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OrderTabButton(
                  label: 'Delivered',
                  isSelected: selectedStatus == 'Delivered',
                  onPressed: () => updateSelectedStatus('Delivered'),
                ),
                OrderTabButton(
                  label: 'Processing',
                  isSelected: selectedStatus == 'Processing',
                  onPressed: () => updateSelectedStatus('Processing'),
                ),
                OrderTabButton(
                  label: 'Canceled',
                  isSelected: selectedStatus == 'Canceled',
                  onPressed: () => updateSelectedStatus('Canceled'),
                ),
              ],
            ),
          ),

          Expanded(
            child: dbHelper.getData(path: 'orders', columnFilter: 'shippingStatus', filterValue: selectedStatus,
             itemBuilder: (orders) {
              return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                var order = orders[index];
                return OrderCard(
                  id: order['id'],
                  trackingNumber: order['trackingNumber'],
                  quantity: order['itemCount'],
                  totalAmount: order['totalAmount'],
                  expiryDate: order['createdAt'].toDate(),
                  status: order['shippingStatus'],
                  );
                },
              );
            }
          ),
        ),
      ],
    ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}

class OrderTabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  OrderTabButton({
    required this.label,
    required this.isSelected,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.orange : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String id;
  final String trackingNumber;
  final int quantity;
  final int totalAmount;
  final DateTime expiryDate;
  final String status;

  OrderCard({
    required this.id,
    required this.trackingNumber,
    required this.quantity,
    required this.totalAmount,
    required this.expiryDate,
    required this.status,
});

  @override
  Widget build(BuildContext context) {

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order# $id', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${expiryDate.day}/${expiryDate.month}/${expiryDate.year}', style: TextStyle(color: Colors.grey)),
              ],
            ),
            SizedBox(height: 8),

            Text('Tracking number: $trackingNumber', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Quantity: $quantity'),
                Text('Total Amount: \$${totalAmount}', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {},
                  child: Text('Details'),
                ),
                Text(
                  status,
                  style: TextStyle(color: status == "Delivered"
                                            ? Colors.green : status == "Processing"
                                            ? Colors.amber[800] : Colors.red
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
