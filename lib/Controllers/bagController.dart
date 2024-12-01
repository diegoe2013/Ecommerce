import 'package:flutter/material.dart';
import 'package:untitled/Controllers/databaseHelper.dart';
import 'package:untitled/Models/bag_item.dart';
import 'package:uuid/uuid.dart';

class BagController {
  final DBHelper _dbHelper = DBHelper();
  String _bagId = '';
  String _userId = '';
  List<BagItem> _bagItems = [];
  double _totalPrice = 0.0;

  String get bagId => _bagId;
  // Getter for Bag Items
  List<BagItem> get bagItems => List.unmodifiable(_bagItems);

  // Getter for Total Price
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

  // Get or Create Bag for a user
  Future<String> _getOrCreateBag(String userId) async {
    try {
      // Query Firestore to find a bag for the user
      final bags = await _dbHelper.fetchData('bags', 'userId', userId);

      if (bags.isNotEmpty) {
        // If a bag exists, return its ID
        return bags.first['bagId'];
      } else {
        // If no bag exists, create a new one
        final newBagId = const Uuid().v4();
        await _initializeBag(userId, newBagId);
        return newBagId;
      }
    } catch (e) {
      debugPrint('Error getting or creating bag: $e');
      return '';
    }
  }

  // Add item to Bag
  Future<void> addItemToBag(String userId, BagItem item) async {
    try {
      // Verify if a bag exists for the user
      _bagId = await _getOrCreateBag(userId);
      // Fetch the bag's existing data
      final path = 'bags/$_bagId';
      final bagData = await _dbHelper.fetchData(path, null, null);

      if (bagData.isNotEmpty) {
        // If the bag exists, update items and total price
        _bagItems = (bagData.first['items'] as List).map((item) => BagItem.fromJson(item)).toList();
        _totalPrice = bagData.first['totalPrice'];
      }

      //  Check if the product is already in the bag
      final existingIndex = _bagItems.indexWhere((bagItem) => bagItem.id == item.id);
      if (existingIndex >= 0) {
        // Increment quantity if the item already exists
        _bagItems[existingIndex].quantity += item.quantity;
      } else {
        // Add the new product
        _bagItems.add(item);
      }

      // Calculate the new total price
      _totalPrice = _bagItems.fold(0.0, (sum, item) => sum + item.price * item.quantity);

      // Save the updated bag to Firebase
      final updatedBagData = {
        'bagId': _bagId,
        'userId': userId,
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

  // Initialize a new Bag
  Future<void> _initializeBag(String userId, String newBagId) async {
    try {
      final initialBagData = {
        'bagId': _bagId,
        'userId': userId,
        'items': [],
        'totalPrice': 0.0,
      };
      await _dbHelper.addData('bags/$newBagId', initialBagData);
    } catch (e) {
      debugPrint('Error initializing bag: $e');
    }
  }
}
