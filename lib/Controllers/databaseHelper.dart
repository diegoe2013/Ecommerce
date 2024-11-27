import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DBHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addData(String path, Map<String, dynamic> data) async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection(path);
    await collection.add(data);
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
          return const Center(child: Text("No orders found"));
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

  Future<Map<String, dynamic>?> accessReference(DocumentReference<Map<String, dynamic>> ref) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();

    if (snapshot.exists) {
      return snapshot.data();
    } else {
      return null; 
    }
  } 
}


