import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// import 'Views/profile.dart';
import 'Controllers/databaseHelper.dart';
import 'Views/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Demo',
      home: Welcome(),
    );
  }
}

