import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DBHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addData(String path, Map<String, dynamic> data) async {
    DocumentReference docRef = FirebaseFirestore.instance.doc(path);

    await docRef.set(data); 
  }

  //funcion original comentada
  // String autoIncrement(List<Map<String, dynamic>> data) {
  //   int max = 0;
  //   for (int i = 0; i < data.length; i++) {
  //     int id = int.parse(data[i]['id']);

  //     if (id > max) {
  //       max = id;
  //     }
  //   }

  //   return (max + 1).toString();
  // }

    // Future<int> autoIncrement(String path) async {
    //   final collectionRef = FirebaseFirestore.instance.collection(path);

    //   // Ordenar por ID en orden descendente y limitar a 1. ahi tenemos el ultimo
    //   final querySnapshot = await collectionRef
    //       .orderBy('id', descending: true)
    //       .limit(1)
    //       .get();

    //   // Si hay documentos, obtener el ID más alto, sino iniciar en 1
    //   if (querySnapshot.docs.isNotEmpty) {
    //     final lastId = querySnapshot.docs.first['id'];

    //     // Convertir el ID a int por si es string en la base de datos
    //     try {
    //       return int.parse(lastId.toString()) + 1;
    //     } catch (e) {
    //       throw Exception("El valor de 'id' no es un entero válido: $lastId");
    //     }
    //   } else {
    //     return 1; // Si no hay datos, comenzamos con 1
    //   }
    // }

  Future autoIncrement(String path) async {
    final collectionRef = FirebaseFirestore.instance.collection(path);

    // Ordenar por ID en orden descendente y limitar a 1
    final querySnapshot = await collectionRef
        .orderBy('id', descending: true)
        .limit(1)
        .get();

    // Si hay documentos, obtener el ID más alto, sino iniciar en 1
    if (querySnapshot.docs.isNotEmpty) {
      final lastId = querySnapshot.docs.first['id'];
      return (int.parse(lastId)  + 1).toString();
    } else {
      return 1.toString(); // Si no hay datos, comenzamos con 1
    }
  }

  Future<void> deleteData(String path) async {
    await _firestore.doc(path).delete();
  }

  Future<void> updateData(String path, Map<String, dynamic> data) async {
    await _firestore.doc(path).update(data);
  }

  FutureBuilder<List<Map<String, dynamic>>> getData({
    required String path,
    String? columnFilter,
    String? filterValue,
    required Widget Function(List<Map<String, dynamic>>) itemBuilder,
  }) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchData(path, columnFilter, filterValue),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading orders"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No data found"));
        } else {
          return itemBuilder(snapshot.data!);
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchData(
      String path, String? columnFilter, String? columnFilterValue) async {
    Query query = _firestore.collection(path);

    if (columnFilter != null && columnFilterValue != null) {
      query = query.where(columnFilter, isEqualTo: columnFilterValue);
    }

    QuerySnapshot snapshot = await query.get();

    return snapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();
  }

  Future<Map<String, dynamic>?> accessReference(
      DocumentReference<Map<String, dynamic>> ref) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();

    if (snapshot.exists) {
      return snapshot.data();
    } else {
      return null;
    }
  }
}
