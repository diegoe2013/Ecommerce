import 'package:flutter/material.dart';
import 'package:untitled/Controllers/databaseHelper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckoutController {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DBHelper _dbHelper = DBHelper();
  String _userId = '';

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

  // Process Payment with Stripe
  Future<void> processPayment(double amount, Map<String, dynamic> paymentMethod) async {
    try {
      // Validate payment method information
      if (!paymentMethod.containsKey('cardNumber') ||
          !paymentMethod.containsKey('expiryDate') ||
          !paymentMethod.containsKey('type')) {
        throw Exception('Payment method information is incomplete.');
      }

      // Create a Stripe PaymentIntent
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer sk_test_51QRRS7DjvqEatelqPJ75h1tt61ipzvhbDULjCLvL8dj4BiHpULIFs27jsakJRU3AIpN3mdptSOhbKjIEpVY2QLWD008eAHxHLq',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': (amount * 100).toInt().toString(),
          'currency': 'usd', // default to usd
          'payment_method_types[]': 'card',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al crear el PaymentIntent: ${response.body}');
      }

      final paymentIntentData = json.decode(response.body);

      // Validate PaymentIntent data
      final confirmResponse = await http.post(
        Uri.parse(
            'https://api.stripe.com/v1/payment_intents/${paymentIntentData['id']}/confirm'),
        headers: {
          'Authorization': 'Bearer sk_test_YOUR_SECRET_KEY',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'payment_method_data[type]': 'card',
          'payment_method_data[card][number]': paymentMethod['cardNumber'],
          'payment_method_data[card][exp_month]': paymentMethod['expiryDate']
              .split('/')[0],
          'payment_method_data[card][exp_year]': paymentMethod['expiryDate']
              .split('/')[1],
          'payment_method_data[card][cvc]': '123',
        },
      );

      if (confirmResponse.statusCode != 200) {
        throw Exception('Error al confirmar el pago: ${confirmResponse.body}');
      }

      debugPrint('Pago procesado exitosamente.');
    } catch (e) {
      throw Exception('Error procesando el pago: $e');
    }
  }
}