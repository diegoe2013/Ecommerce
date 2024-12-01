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

  // Fetch Bag for a user using DBHelper
  Future<void> fetchBag(String bagId) async {
    try {
      final path = 'bags/$bagId';
      final bagData = await _dbHelper.fetchData(path, null, null);

      if (bagData.isNotEmpty) {
        final bag = bagData.first;
        _bagId = bagId;
        _userId = bag['userId'];
        _bagItems = (bag['items'] as List)
            .map((item) => BagItem.fromJson(item))
            .toList();
        _totalPrice = bag['totalPrice'];
      }
    } catch (e) {
      debugPrint('Error fetching bag: $e');
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

  // Remove item from Bag
  Future<void> removeItemFromBag(String productId) async {
    try {
      final existingIndex = _bagItems.indexWhere((bagItem) => bagItem.id == productId);
      if (existingIndex >= 0) {
        _bagItems.removeAt(existingIndex);
      }

      _totalPrice = _bagItems.fold(0.0, (sum, item) => sum + item.price * item.quantity);

      final bagData = {
        'items': _bagItems.map((item) => item.toJson()).toList(),
        'totalPrice': _totalPrice,
      };

      await _dbHelper.updateData('bags/$_bagId', bagData);
    } catch (e) {
      debugPrint('Error removing item from bag: $e');
    }
  }
  // Update item quantity
  Future<void> updateItemQuantity(String userId, String productId, int quantity) async {
    try {
      final existingIndex = _bagItems.indexWhere((bagItem) => bagItem.id == productId);
      if (existingIndex >= 0) {
        _bagItems[existingIndex].quantity = quantity;
      }

      _totalPrice = _bagItems.fold(0.0, (sum, item) => sum + item.price * item.quantity);

      final bagData = {
        'items': _bagItems.map((item) => item.toJson()).toList(),
        'totalPrice': _totalPrice,
      };

      await _dbHelper.updateData('bags/$userId', bagData);
    } catch (e) {
      debugPrint('Error updating item quantity: $e');
    }
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

  // Initialize a new Bag
  Future<void> _initializeBag(String userId, String newBagId) async {
    try {
      final initialBagData = {
        'bagId': newBagId,
        'userId': userId,
        'items': [],
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
