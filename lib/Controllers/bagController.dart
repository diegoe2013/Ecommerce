import 'package:flutter/material.dart';
import 'package:untitled/Controllers/databaseHelper.dart';
import 'package:untitled/Models/bag_item.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BagController {
  final DBHelper _dbHelper = DBHelper();
  String _bagId = '';
  String _userId = '';
  List<BagItem> _bagItems = [];
  double _totalPrice = 0.0;

  String get bagId => _bagId;
  List<BagItem> get bagItems => List.unmodifiable(_bagItems);
  double get totalPrice => _totalPrice;

  // Fetch Bag for a user (list of items on the bag and total price)
  Future<void> fetchBag() async {
    try {
      _bagId = await _getOrCreateBag();
      final path = 'bags/$_bagId';
      final bagDoc = await FirebaseFirestore.instance.doc(path).get();

      if (bagDoc.exists) {
        final bagData = bagDoc.data();
        if (bagData != null) {
          _bagItems = (bagData['items'] as List<dynamic>)
              .map((item) => BagItem.fromJson(item))
              .toList();
          _totalPrice = bagData['totalPrice'] ?? 0.0;
        }
      } else {
        debugPrint('No bag found with ID: $bagId');
      }
    } catch (e) {
      debugPrint('Error fetching bag items and total price: $e');
    }
  }

  // Add item to Bag
  Future<void> addItemToBag(BagItem item) async {
    try {
      _bagId = await _getOrCreateBag();
      final path = 'bags/$_bagId';
      final bagDoc = await FirebaseFirestore.instance.doc(path).get();

      if (bagDoc.exists) {

        final List<dynamic> currentItems = bagDoc.data()?['items'] ?? [];
        bool itemUpdated = false;

        for (var i = 0; i < currentItems.length; i++) {
          if (currentItems[i]['title'] == item.title) {
            currentItems[i]['quantity'] += item.quantity;
            itemUpdated = true;
            break;
          }
        }

        if (!itemUpdated) {
          currentItems.add(item.toJson());
        }

        final double updatedTotalPrice = currentItems.fold<double>(
          0.0,
              (sum, currentItem) =>
          sum + (currentItem['price'] * currentItem['quantity']),
        );

        await FirebaseFirestore.instance.doc(path).update({
          'items': currentItems,
          'totalPrice': updatedTotalPrice,
        });

        _bagItems = currentItems.map((item) => BagItem.fromJson(item)).toList();
        _totalPrice = updatedTotalPrice;
      } else {
        await _initializeBag(_userId, _bagId);
        await addItemToBag(item);
      }
    } catch (e) {
      debugPrint('Error adding item to bag: $e');
    }
  }

  // Update item quantity
  Future<void> updateItemQuantity(String productId, int newQuantity) async {
    if (newQuantity < 1) {
      debugPrint('Quantity cannot be less than 1');
      return;
    }

    final existingIndex = _bagItems.indexWhere((item) => item.id == productId);

    if (existingIndex != -1) {
      _bagItems[existingIndex].quantity = newQuantity;

      // New price
      _totalPrice = _bagItems.fold(
        0.0,
            (sum, item) => sum + (item.price * item.quantity),
      );

      // Update database
      final bagData = {
        'items': _bagItems.map((item) => item.toJson()).toList(),
        'totalPrice': _totalPrice,
      };
      await _dbHelper.updateData('bags/$_bagId', bagData);
    }
  }

  // Remove item from Bag
  Future<void> removeItemFromBag(String productId) async {
    _bagItems.removeWhere((item) => item.id == productId);

    // New price
    _totalPrice = _bagItems.fold(
      0.0,
          (sum, item) => sum + (item.price * item.quantity),
    );

    // Update database
    final bagData = {
      'items': _bagItems.map((item) => item.toJson()).toList(),
      'totalPrice': _totalPrice,
    };
    await _dbHelper.updateData('bags/$_bagId', bagData);
  }

  // Get or Create Bag for a user
  Future<String> _getOrCreateBag() async {
    try {
      // Query Firestore to find a bag for the user
      _userId = await _getUserIdByEmail();

      if (_userId.isEmpty) {
        throw Exception('User ID not found for authenticated user');
      }

      final bags = await _dbHelper.fetchData('bags', 'userId', _userId);

      if (bags.isNotEmpty) {
        // If a bag exists, return its ID
        return bags.first['bagId'];
      } else {
        // If no bag exists, create a new one
        final newBagId = const Uuid().v4();
        await _initializeBag(_userId, newBagId);
        return newBagId;
      }
    } catch (e) {
      debugPrint('Error getting or creating bag: $e');
      return '';
    }
  }

  // Apply Promo Code
  Future<void> addPromoCode(String promoCode) async {
    try {
      final path = 'bags/$_bagId';
      final bagDoc = await FirebaseFirestore.instance.doc(path).get();

      if (!bagDoc.exists) {
        throw Exception('Bag not found.');
      }

      final bagData = bagDoc.data();
      if (bagData != null && bagData['promoCode'] != null) {
        throw Exception('A promo code has already been applied.');
      }

      final promoDoc = await FirebaseFirestore.instance
          .collection('global_promoCodes')
          .where('code', isEqualTo: promoCode)
          .get();

      if (promoDoc.docs.isEmpty) {
        throw Exception('Promo code not found.');
      }
      final promoData = promoDoc.docs.first.data();
      final discount = promoData['%discount'] ?? 0.0;
      final discountedPrice = _totalPrice - (_totalPrice * discount);
      await FirebaseFirestore.instance.doc(path).update({
        'promoCode': promoCode,
        'totalPrice': discountedPrice,
      });
      _totalPrice = discountedPrice;
    } catch (e) {
      throw Exception('Could not apply promo code.');
    }
  }

  // Remove Promo Code
  Future<void> removePromoCode() async {
    try {
      final path = 'bags/$_bagId';
      final bagDoc = await FirebaseFirestore.instance.doc(path).get();

      if (!bagDoc.exists) {
        throw Exception('Bag not found.');
      }

      final bagData = bagDoc.data();
      if (bagData == null || bagData['promoCode'] == null) {
        throw Exception('No promo code applied.');
      }

      final currentDiscount = bagData['promoCode'] != null
          ? (bagData['%discount'] ?? 0.0)
          : 0.0;

      final originalTotalPrice = _totalPrice / (1 - currentDiscount);

      await FirebaseFirestore.instance.doc(path).update({
        'promoCode': null,
        'totalPrice': originalTotalPrice,
        '%discount': null,
      });

      _totalPrice = originalTotalPrice;
    } catch (e) {
      debugPrint('Error removing promo code: $e');
      throw Exception('Could not remove promo code.');
    }
  }

  // Initialize a new Bag
  Future<void> _initializeBag(String userId, String newBagId) async {
    try {
      final initialBagData = {
        'bagId': newBagId,
        'userId': userId,
        'items': [],
        'promoCode': null,
        'totalPrice': 0.00,
      };
      await _dbHelper.addData('bags/$newBagId', initialBagData);
    } catch (e) {
      debugPrint('Error initializing bag: $e');
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
}
