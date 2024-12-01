import 'package:flutter/material.dart';
import 'package:untitled/Controllers/databaseHelper.dart';
import 'package:untitled/Models/bag_item.dart';
import 'package:uuid/uuid.dart';

class BagController {
  final DBHelper _dbHelper = DBHelper();
  String _bagId = const Uuid().v4();
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

  // Add item to Bag
  Future<void> addItemToBag(String userId, BagItem item) async {
    try {
      // Ruta del Bag en Firebase
      final path = 'bags/$_bagId';

      // Verificar si el Bag ya existe
      final bagData = await _dbHelper.fetchData(path, null, null);

      if (bagData.isNotEmpty) {
        // Si el Bag ya existe, actualizar sus items
        _bagItems = (bagData.first['items'] as List)
            .map((item) => BagItem.fromJson(item))
            .toList();
        _totalPrice = bagData.first['totalPrice'];
      } else {
        // Si el Bag no existe, inicializar uno nuevo
        _bagId = const Uuid().v4();
        await _initializeBag(userId);
      }

      // Verificar si el producto ya está en el Bag
      final existingIndex = _bagItems.indexWhere((bagItem) => bagItem.id == item.id);
      if (existingIndex >= 0) {
        // Incrementar cantidad si ya existe
        _bagItems[existingIndex].quantity += item.quantity;
      } else {
        // Agregar nuevo producto
        _bagItems.add(item);
      }

      // Calcular el total
      _totalPrice = _bagItems.fold(0.0, (sum, item) => sum + item.price * item.quantity);

      // Guardar Bag actualizado en Firebase
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
  Future<void> _initializeBag(String userId) async {
    try {
      final initialBagData = {
        'bagId': _bagId,
        'userId': userId,
        'items': [],
        'totalPrice': 0.0,
      };
      await _dbHelper.addData('bags/$_bagId', initialBagData);
    } catch (e) {
      debugPrint('Error initializing bag: $e');
    }
  }
}
