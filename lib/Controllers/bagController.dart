import 'package:flutter/material.dart';
import 'package:untitled/Controllers/databaseHelper.dart';
import 'package:untitled/Models/bag_item.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      // Verify if a bag exists for the user
      _bagId = await _getOrCreateBag();
      // Fetch the bag's existing data
      final path = 'bags/$_bagId';

      //  Check if the product is already in the bag
      final existingProduct = _bagItems.indexWhere((bagItem) => bagItem.title == item.title);
      if (existingProduct >= 0) {
        // Increment quantity if the item already exists
        _bagItems[existingProduct].quantity += item.quantity;
      } else {
        _bagItems.add(item);
      }

      // Calculate the total price
      _totalPrice += item.price * item.quantity;

      // Save the updated bag to Firebase
      final updatedBagData = {
        'bagId': _bagId,
        'userId': _userId,
        'items': _bagItems.map((item) => item.toJson()).toList(),
        'totalPrice': _totalPrice,
      };

      await _dbHelper.addData(path, updatedBagData);
    } catch (e) {
      debugPrint('Error adding item to bag: $e');
    }
  }

  // Remove item from Bag
  Future<void> removeItemFromBag(String userId, String productId) async {
    try {
      _bagItems.removeWhere((item) => item.id == productId);
      _totalPrice = _bagItems.fold(0.0, (sum, item) => sum + item.price * item.quantity);

      final bagData = {
        'items': _bagItems.map((item) => item.toJson()).toList(),
        'totalPrice': _totalPrice,
      };

      await _dbHelper.updateData('bags/$userId', bagData);
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
