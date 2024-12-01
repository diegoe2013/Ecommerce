import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> isAuthenticated() async {
    final user = FirebaseAuth.instance.currentUser;
    return user != null; // Retorna true si hay un usuario autenticado
  }

  Future createAcount(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      print(userCredential.user);
      return (userCredential.user?.uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('the password provided is too weak');
        return 1;
      } else if (e.code == 'email-already-in-use') {
        print('the account already exist for that email');
        return 2;
      }
    } catch (e) {
      print(e);
    }
  } //create acount

  Future<dynamic> signInEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      final user = userCredential.user;
      if (user?.uid != null) {
        return user?.uid;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        debugPrint('Error: Usuario no encontrado');
        return 1;
      } else if (e.code == 'wrong-password') {
        debugPrint('Error: Contraseña incorrecta');
        return 2;
      } else {
        debugPrint('Error inesperado: ${e.code}');
        return 3; 
      }
    } catch (e) {
      debugPrint('Error inesperado no manejado: $e');
      return 4; // otros errores no relacionados con Firebase.
    }
  }



  Future passwordReset(BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('password Reset Link sent, check your email'),
            );
          });
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  //  verificar si el usuario está autenticado
  User? get currentUser => _auth.currentUser;

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
