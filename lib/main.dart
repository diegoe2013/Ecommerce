import 'package:untitled/Controllers/payment_server.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/Views/forgot_password.dart';
import 'package:untitled/Views/my_orders.dart';
import 'package:untitled/Views/payment_methods.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

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
import 'Views/categories.dart';
import 'Controllers/auth_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  Stripe.publishableKey = 'pk_test_51QRRS7DjvqEatelq6BtphwzT621UhvjoB9I6plQsu3l9V3hbctk8q1DsOpR6A8sKlFF51j7OAVChKwovJfExFSmA00S5RUC7Qr';
  await Firebase.initializeApp();
  startServer();

  final user = FirebaseAuth.instance.currentUser;

  // Define initialRoute dinámicamente
  runApp(MyApp(initialRoute: user == null ? '/welcome' : '/home'));
}

class MyApp extends StatelessWidget {
  final String initialRoute; // Declaración de la propiedad

  const MyApp({required this.initialRoute, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ecommerce App',
      initialRoute: initialRoute, // Usa la ruta inicial proporcionada
      routes: {
        '/create_account': (context) =>  CreateAccount(),
        '/login': (context) =>  Login(),
        '/forgot_password': (context) =>  ForgotPassword(),
        '/home': (context) => const HomeScreen(initialCategory: 'clothes'),
        '/my_orders': (context) => const MyOrders(),
        '/profile': (context) => AuthGuard(
              child: Profile(),
            ),
        '/welcome': (context) => const Welcome(),
        '/my_bag': (context) => const MyBag(),
        '/settings': (context) =>  Settings(),
        '/favorites': (context) =>  const Favorites(),
        '/payment_methods': (context) =>  const PaymentMethods(),
        '/categories': (context) => Category(),
      },
    );
  }
}
