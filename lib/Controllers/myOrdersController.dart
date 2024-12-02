import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/Controllers/databaseHelper.dart';
import 'package:untitled/Controllers/bagController.dart';

class MyOrdersController {
  final DBHelper _dbHelper = DBHelper();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BagController _bagController = BagController();

  Future<void> createOrder() async {
    try {
      final userId = await _getUserIdByEmail();
      final deliveryAddress = await _getDeliveryAddress(userId);
      final paymentMethod = await _getPaymentMethod(userId);

      await _bagController.fetchBag();
      final bagItems = _bagController.bagItems;
      final totalPrice = _bagController.totalPrice;

      if (bagItems.isEmpty) {
        throw Exception('No items in bag');
      }

      final nextId = await _getNextOrderId();

      final orderData = {
        'id': nextId, // ID incremental
        'userId': userId,
        'paymentMethod': {
          'cardNumber': paymentMethod['cardNumber'],
          'expiryDate': paymentMethod['expiryDate'],
          'type': paymentMethod['type'],
        },
        'deliveryAddress': {
          'city': deliveryAddress['city'],
          'country': deliveryAddress['country'],
          'street': deliveryAddress['street'],
        },
        'items': bagItems.map((item) => item.toJson()).toList(),
        'totalAmount': totalPrice,
        'discount': 0.00,
        'itemCount': bagItems.length,
        'shippingStatus': 'Processing',
        'trackingNumber': 'xxxx-xxxx-xxxx',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('orders').doc(nextId.toString()).set(orderData);

      await _clearBag(_bagController.bagId);
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  Future<String> _getNextOrderId() async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .orderBy('id', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final lastId = int.parse(querySnapshot.docs.first['id'] as String);
        return (lastId + 1).toString();
      } else {
        return '1';
      }
    } catch (e) {
      throw Exception('Error fetching next order ID: $e');
    }
  }

  // Fetch delivery address from user
  Future<Map<String, dynamic>> _getDeliveryAddress(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['deliveryAddress'] ?? {};
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      throw Exception('Error fetching delivery address: $e');
    }
  }

  // Fetch payment method
  Future<Map<String, dynamic>> _getPaymentMethod(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['paymentMethods'] ?? {};
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      throw Exception('Error fetching payment method: $e');
    }
  }

  // Clear bag after order is created
  Future<void> _clearBag(String bagId) async {
    try {
      await _firestore.collection('bags').doc(bagId).update({
        'items': [],
        'totalPrice': 0.0,
      });
    } catch (e) {
      throw Exception('Error clearing bag: $e');
    }
  }

  // Fetch userId from email
  Future<String> _getUserIdByEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        throw Exception('User not authenticated');
      }

      final userEmail = user.email!;
      final users = await _dbHelper.fetchData('users', 'email', userEmail);

      if (users.isNotEmpty) {
        return users.first['id'];
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      throw Exception('Error fetching user ID: $e');
    }
  }
}
