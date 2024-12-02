import 'package:flutter/material.dart';
import 'package:untitled/Controllers/databaseHelper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/Models/bag_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutController {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DBHelper _dbHelper = DBHelper();
  String _bagId = '';
  String _userId = '';
  List<BagItem> _bagItems = [];
  double _totalPrice = 0.0;

  // Fetch default Shipping Address
  Future<Map<String, dynamic>> fetchShippingAddress() async {
    _userId = await _getUserIdByEmail();
    try {
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(_userId).get();

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      return userData['deliveryAddress'] ?? {};
    } catch (e) {
      throw Exception('Error fetching shipping address: $e');
    }
  }

  // Fetch default Payment Method
  Future<Map<String, dynamic>> fetchPaymentMethods() async {
    _userId = await _getUserIdByEmail();
    try {
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(_userId).get();

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      return userData['paymentMethods'] ?? {};
    } catch (e) {
      throw Exception('Error fetching payment methods: $e');
    }
  }

  // Get userId from email
  Future<String> _getUserIdByEmail() async {
    try {
      // Get the email of the authenticated user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        throw Exception('User not authenticated');
      }

      final userEmail = user.email!;
      debugPrint('Authenticated User Email: $userEmail');

      // Query the 'users' collection to find the user with the given email
      final users = await _dbHelper.fetchData('users', 'email', userEmail);

      if (users.isNotEmpty) {
        return users.first['id'];
      } else {
        return '';
      }
    } catch (e) {
      debugPrint('Error fetching userId by email: $e');
      return '';
    }
  }

  // Fetch Delivery Methods
  Future<List<Map<String, dynamic>>> fetchDeliveryMethods() async {
    try {
      final QuerySnapshot deliveryMethodsSnapshot =
      await _firestore.collection('global_deliveryMethods').get();

      return deliveryMethodsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': data['id'],
          'provider': data['provider'],
          'dailyFee': double.parse(data['dailyFee']),
        };
      }).toList();
    } catch (e) {
      throw Exception('Error fetching delivery methods: $e');
    }
  }
}