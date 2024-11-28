import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:untitled/Views/forgot_password.dart';
import 'package:untitled/Views/my_orders.dart';
import 'package:untitled/Views/payment_methods.dart';

// import 'Views/profile.dart';
import 'Controllers/databaseHelper.dart';

// Views
import 'Views/create_account.dart';
import 'Views/home.dart';
import 'Views/login.dart';
import 'Views/Profile.dart';
import 'Views/welcome.dart';
import 'Views/my_bag.dart';
import 'Views/settings.dart';
import 'Views/favorites.dart';



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
      title: 'Ecommerce App',
      initialRoute: '/welcome',
      routes: {
        '/create_account': (context) =>  CreateAccount(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) =>  Login(),
        '/forgot_password': (context) =>  ForgotPassword(),
        '/my_orders': (context) => const MyOrders(),
        '/profile': (context) => Profile(),
        '/welcome': (context) => const Welcome(),
        '/my_bag': (context) => const MyBag(),
        '/settings': (context) =>  Settings(),
        '/favorites': (context) =>  const Favorites(),
        '/payment_methods': (context) =>  const PaymentMethods(),



      },
    );
  }
}

