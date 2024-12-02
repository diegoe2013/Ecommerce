import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untitled/Controllers/databaseHelper.dart';
import 'package:untitled/Views/create_account.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _Settings createState() => _Settings();
}

class _Settings extends State<Settings> {
  final DBHelper dbHelper = DBHelper();
  final user = FirebaseAuth.instance.currentUser;
  String userId = '0';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late bool _field1;
  late bool _field2;
  late bool _field3;

  void updateTextSettings() {
    if (_birthdayController.text != "") {
      List<String> parts = _birthdayController.text.split('/');
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      DateTime dateTime = DateTime(year, month, day);
      final input2 = Timestamp.fromDate(dateTime);
      dbHelper.updateData("users/$userId", {'birthDate': input2});
    }

    final input1 = _nameController.text;
    final input3 = _passwordController.text;

    if (input1 != "") dbHelper.updateData("users/$userId", {'name': input1});
    if (input3 != "") {
      user!.updatePassword(input3);
    }
  }

  void updateBoolSettings() {
    dbHelper.updateData("users/$userId", {
      'settings.deliveryStatusChange': _field3,
      'settings.newArrivals': _field2,
      'settings.sales': _field1,
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
    print(user);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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

          final birthDay = user['birthDate'].toDate();
          _field1 = user['settings']['sales'];
          _field2 = user['settings']['newArrivals'];
          _field3 = user['settings']['deliveryStatusChange'];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                    decoration: InputDecoration(
                      labelText: user['name'],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    controller: _nameController),
                const SizedBox(height: 10),
                TextField(
                    decoration: InputDecoration(
                      labelText:
                      '${birthDay.day.toString()}/${birthDay.month.toString()}/${birthDay.year.toString()}',
                      hintText: 'dd/mm/yyyy',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    controller: _birthdayController,
                    keyboardType: TextInputType.datetime),
                const SizedBox(height: 20),
                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          controller: _passwordController),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () => updateTextSettings(),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(color: Colors.purple),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  value: _field1,
                  onChanged: (value) {
                    setState(() {
                      _field1 = value;
                    });
                    updateBoolSettings();
                  },
                  title: const Text('Sales'),
                  activeColor: Colors.green,
                ),
                SwitchListTile(
                  value: _field2,
                  onChanged: (value) {
                    setState(() {
                      _field2 = value;
                    });
                    updateBoolSettings();
                  },
                  title: const Text('New arrivals'),
                  activeColor: Colors.green,
                ),
                SwitchListTile(
                  value: _field3,
                  onChanged: (value) {
                    setState(() {
                      _field3 = value;
                    });
                    updateBoolSettings();
                  },
                  title: const Text('Delivery status changes'),
                  activeColor: Colors.green,
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
        currentIndex: 2,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {},
      ),
    );
  }
}
