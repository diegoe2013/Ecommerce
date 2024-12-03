import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/Controllers/databaseHelper.dart';
import 'package:untitled/Views/create_account.dart';
import 'package:untitled/Views/my_orders.dart';
import 'package:untitled/Views/payment_methods.dart';
import 'package:untitled/Views/settings.dart';
import 'package:untitled/Views/shippingAddress.dart';
import 'package:untitled/Controllers/auth.dart';

class Profile extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;
  String userId = '0';
  final DBHelper dbHelper = DBHelper();
  final AuthService _auth = AuthService();

  Profile({super.key});

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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: dbHelper.getData(
          path: 'users',
          columnFilter: 'email',
          filterValue: user!.email,
          itemBuilder: (users) {
            var user = users[0];
            userId = user['id'];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 35,
                        backgroundImage:
                        AssetImage('assets/profile_picture.png'),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user['email'],
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ProfileOption(
                  title: 'My orders',
                  subtitle: 'Your orders',
                  icon: Icons.chevron_right,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyOrders()),
                    );
                  },
                ),
                const Divider(),
                ProfileOption(
                  title: 'Shipping addresses',
                  subtitle: 'Delivery addresses',
                  icon: Icons.chevron_right,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ShippingAddress()),
                    );
                  },
                ),
                const Divider(),
                ProfileOption(
                  title: 'Payment methods',
                  subtitle: user['paymentMethods']['cardNumber'] == null
                      ? 'No cards'
                      : '${user['paymentMethods']['type']} **${user['paymentMethods']['cardNumber'].toString().substring(14)}',
                  icon: Icons.chevron_right,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PaymentMethods()),
                    );
                  },
                ),
                const Divider(),
                ProfileOption(
                  title: 'Settings',
                  subtitle: 'Notifications, password',
                  icon: Icons.chevron_right,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Settings()),
                    );
                  },
                ),
                ProfileOption(
                title: 'log out',
                subtitle: 'log out and see you later!',
                icon: Icons.chevron_right,
                onTap: () async {
                await _auth.signOut();
                Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
                );
                },
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const ProfileOption({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(icon),
      onTap: onTap,
    );
  }
}
