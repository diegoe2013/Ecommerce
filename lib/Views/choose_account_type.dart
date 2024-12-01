import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'create_account.dart';
import 'login.dart';

class ChooseAccountType extends StatelessWidget {
  const ChooseAccountType({super.key});

  // Función para actualizar el campo userType del último usuario creado
  Future<void> _updateUserType(String userType) async {
    try {
      // Referencia a la colección "users".
      final collectionRef = FirebaseFirestore.instance.collection('users');

      // Obtener el último usuario creado (ordenado por 'id' descendente y limitando a 1).
      final querySnapshot = await collectionRef
          .orderBy('id', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first; // El primer documento en el resultado.
        final userId = doc.id; // ID del documento.

        // Actualizar el campo 'userType' del último usuario.
        await collectionRef.doc(userId).update({'userType': userType});
        debugPrint('Campo userType actualizado a "$userType" para el usuario con ID: $userId');
      } else {
        debugPrint('No se encontró ningún usuario.');
      }
    } catch (e) {
      debugPrint('Error al actualizar userType: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your\nAccount type',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _updateUserType('seller'); // Actualiza a "seller".
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Seller account',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _updateUserType('customer'); // Actualiza a "customer".
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Customer account',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () {
                  //todo aqui ponle una funcion para que se le haga rollback al user
                  Navigator.pop(
                    context,
                    MaterialPageRoute(builder: (context) =>  CreateAccount()),
                  );
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
