import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/Models/favorite_item.dart';
import 'package:untitled/Controllers/databaseHelper.dart';
import 'package:uuid/uuid.dart';

class FavoritesController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DBHelper _dbHelper = DBHelper(); // Asegúrate de tener la implementación de DBHelper
  String _userId = '';

  // Obtener el userId a partir del correo electrónico del usuario autenticado
  Future<String> _getUserIdByEmail() async {
    try {
      // Obtener el usuario autenticado
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        throw Exception('Usuario no autenticado');
      }

      final userEmail = user.email!;
      //debugPrint('Correo autenticado: $userEmail');

      // Consultar la colección 'users' para obtener el userId correspondiente al email
      final users = await _dbHelper.fetchData('users', 'email', userEmail);

      if (users.isNotEmpty) {
        return users.first['id'];
      } else {
        return '';
      }
    } catch (e) {
     // debugPrint('Error obteniendo el userId por email: $e');
      return '';
    }
  }

  // Obtener la lista de favoritos
  Future<List<FavoriteItem>> fetchFavorites() async {
    try {
      _userId = await _getUserIdByEmail();
      if (_userId.isEmpty) {
        throw Exception('User ID no encontrado');
      }

      final docSnapshot = await _firestore.collection('favorites').doc(_userId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data['items'] != null) {
          final items = List<Map<String, dynamic>>.from(data['items']);
          return items.map((item) => FavoriteItem.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error obteniendo favoritos: $e');
      return [];
    }
  }

  Future<void> addFavorite(FavoriteItem item) async {
    try {
      _userId = await _getUserIdByEmail();
      if (_userId.isEmpty) {
        throw Exception('User ID no encontrado');
      }

      final docRef = _firestore.collection('favorites').doc(_userId);

      // Obtener favoritos actuales
      final docSnapshot = await docRef.get();
      List<dynamic> currentItems = [];

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data['items'] != null) {
          currentItems = List<dynamic>.from(data['items']);
        }
      }
      // Verificar si ya existe un producto con el mismo título
      final existingIndex = currentItems.indexWhere((fav) => fav['title'] == item.title);
      if (existingIndex == -1) {
        currentItems.add(item.toJson()); // Agregar solo si no existe
      } else {
        print('El producto ya está en favoritos');
      }

      // Actualizar el documento con los favoritos y el userId
      await docRef.set({
        'userId': _userId, // Guardar el userId en el documento
        'items': currentItems,
      });
    } catch (e) {
      print('Error agregando a favoritos: $e');
    }
  }


  // Eliminar un producto de favoritos
  Future<void> removeFavorite(String itemId) async {
    try {
      _userId = await _getUserIdByEmail();
      if (_userId.isEmpty) {
        throw Exception('User ID no encontrado');
      }

      final docRef = _firestore.collection('favorites').doc(_userId);

      // Obtener favoritos actuales
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data['items'] != null) {
          List<dynamic> currentItems = List<dynamic>.from(data['items']);

          // Eliminar el producto de la lista
          currentItems.removeWhere((item) => item['id'] == itemId);

          // Actualizar el documento con la nueva lista
          await docRef.set({
            'userId': _userId, // Asegurar que el userId sigue almacenado
            'items': currentItems,
          });
        }
      }
    } catch (e) {
      print('Error eliminando de favoritos: $e');
    }
  }
}
