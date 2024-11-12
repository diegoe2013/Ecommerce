import 'package:flutter/material.dart';
import 'package:untitled/Controllers/databaseHelper.dart';
import 'package:untitled/Views/my_orders.dart';
class Profile extends StatelessWidget {
  final DBHelper dbHelper = DBHelper();

  Profile({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage('assets/profile_picture.png'),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Matilda Brown',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'matildabrown@mail.com',
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
            subtitle: 'Already have 12 orders',
            icon: Icons.chevron_right,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyOrders()),
              );
            },
          ),
          const Divider(),
          ProfileOption(
            title: 'Shipping addresses',
            subtitle: '3 addresses',
            icon: Icons.chevron_right,
            onTap: () {}
          ),
          const Divider(),
          ProfileOption(
            title: 'Payment methods',
            subtitle: 'Visa **34',
            icon: Icons.chevron_right,
              onTap: () {}
          ),
          const Divider(),
          ProfileOption(
            title: 'Promocodes',
            subtitle: 'You have special promocodes',
            icon: Icons.chevron_right,
              onTap: () {}
          ),
          const Divider(),
          ProfileOption(
            title: 'My reviews',
            subtitle: 'Reviews for 4 items',
            icon: Icons.chevron_right,
              onTap: () {}
          ),
          const Divider(),
          ProfileOption(
            title: 'Settings',
            subtitle: 'Notifications, password',
            icon: Icons.chevron_right,
              onTap: () {}
          ),
        ],
      ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
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

  const ProfileOption({super.key, 
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: Icon(icon),
      onTap: onTap,
    );
  }
}