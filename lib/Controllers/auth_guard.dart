import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/Views/login.dart';

// class AuthGuard extends StatelessWidget {
//   final Widget child; // La vista protegida

//   const AuthGuard({required this.child, Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         // Mientras verifica el estado
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         // Si el usuario no está autenticado, redirige al login
//         if (snapshot.data == null) {
//           print('Usuario no autenticado, redirigiendo a Login');
//           return const Login();
//         }

//         // Si el usuario está autenticado, muestra la vista protegida
//         print('Usuario autenticado, mostrando vista protegida');
//         return child;
//       },
//     );
//   }
// }



class AuthGuard extends StatelessWidget {
  final Widget child; // La vista protegida

  const AuthGuard({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    // Agrega logs para verificar el valor de user
    if (user == null) {
      print('AuthGuard: Usuario no autenticado (user es null).');
      return const Login();
    } else {
      print('AuthGuard: Usuario autenticado: ${user.email}');
      return child;
    }
  }
}

