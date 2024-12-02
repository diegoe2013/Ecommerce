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
import 'Views/my_orders.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  Stripe.publishableKey = 'pk_test_51QRRS7DjvqEatelq6BtphwzT621UhvjoB9I6plQsu3l9V3hbctk8q1DsOpR6A8sKlFF51j7OAVChKwovJfExFSmA00S5RUC7Qr';
  await Firebase.initializeApp();
  startServer();

  final user = FirebaseAuth.instance.currentUser;
  runApp(MyApp(initialRoute: user == null ? '/welcome' : '/home'));
}

class MyApp extends StatelessWidget {
  final String initialRoute; 

  const MyApp({required this.initialRoute, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ecommerce App',
      initialRoute: initialRoute, 
      routes: {
        '/welcome': (context) => const Welcome(),
        '/create_account': (context) =>  CreateAccount(),
        '/login': (context) =>  Login(),
        '/forgot_password': (context) =>  ForgotPassword(),

        '/home': (context) => const AuthGuard(
          child: HomeScreen(initialCategory: 'clothes'),
        ),

        '/my_orders': (context) => const AuthGuard(
          child:  MyOrders(),
        ),

        '/profile': (context) => AuthGuard(
          child: Profile(),
        ),
        
        '/my_bag': (context) => const AuthGuard(
          child:  MyBag(),
        ),
        
        '/settings': (context) =>  AuthGuard(
          child:  Settings(),
        ),
        
        '/favorites': (context) => const AuthGuard(
          child: FavoritesScreen(),
        ),
        
        '/payment_methods': (context) => const AuthGuard(
          child: PaymentMethods(),
        ),
        
        '/categories': (context) => AuthGuard(
          child: Category(),
        ),
      },
    );
  }//widget build
}//class myapp
