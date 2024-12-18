import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/Controllers/databaseHelper.dart';
import 'package:untitled/Views/create_account.dart';
import 'package:untitled/Views/order_details.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({super.key});

  @override
  _MyOrders createState() => _MyOrders();
}

class _MyOrders extends State<MyOrders> {
  final DBHelper dbHelper = DBHelper();
  String selectedStatus = "Delivered";
  final user = FirebaseAuth.instance.currentUser;
  String userId = '0';

  void updateSelectedStatus(String status) {
    setState(() {
      selectedStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      Navigator.pop(
        context,
        MaterialPageRoute(
          builder: (context) => CreateAccount(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: dbHelper.getData(
        path: 'users',
        columnFilter: "email",
        filterValue: user!.email,
        itemBuilder: (users) {
          final user = users[0];
          userId = user['id'];
          return Column(
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
                child: dbHelper.getData(
                    path: 'orders',
                    columnFilter: 'shippingStatus',
                    filterValue: selectedStatus,
                    itemBuilder: (orders) {
                      return ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          var order = orders[index];
                          print("ORDER");
                          print(order);
                          if (order['userId'] != userId) {
                            return const Center(child: Text("No data found"));
                          }
                          return OrderCard(order: order);
                        },
                      );
                    }),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          }
          if (index == 1) {
            Navigator.pushNamed(context, '/favorites');
          }
          if (index == 2) {
            Navigator.pushNamed(context, '/my_bag');
          }
          if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorite'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class OrderTabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const OrderTabButton(
      {super.key,
        required this.label,
        required this.isSelected,
        required this.onPressed});

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
  final Map<String, dynamic> order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    DateTime date = order['createdAt'].toDate();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order# ${order['id']}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${date.day}/${date.month}/${date.year}',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Tracking number: ${order['trackingNumber']}',
                style: TextStyle(color: Colors.grey)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Quantity: ${order['itemCount']}'),
                Text('Total Amount: \$${order['totalAmount']}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => order_details(order: order),
                      ),
                    );
                  },
                  child: const Text('Details'),
                ),
                Text(
                  order['shippingStatus'],
                  style: TextStyle(
                      color: order['shippingStatus'] == "Delivered"
                          ? Colors.green
                          : order['shippingStatus'] == "Processing"
                          ? Colors.amber[800]
                          : Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
