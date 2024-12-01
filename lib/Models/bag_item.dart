import 'package:uuid/uuid.dart';

class BagItem {
  final String id = const Uuid().v4(); // Generate a UUID automatically
  final String title;
  final double price;
  final String imageUrl;
  final String shortDescription;
  final String brand;
  final String condition;
  int quantity;

  BagItem({
    String? id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.shortDescription,
    required this.brand,
    required this.condition,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'imageUrl': imageUrl,
      'shortDescription': shortDescription,
      'brand': brand,
      'condition': condition,
      'quantity': quantity,
    };
  }

  factory BagItem.fromJson(Map<String, dynamic> json) {
    return BagItem(
      id: json['id'] ?? const Uuid().v4(), // Use UUID if ID is null
      title: json['title'] ?? 'No Title',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
      shortDescription: json['shortDescription'] ?? 'No description',
      brand: json['brand'] ?? 'Unknown',
      condition: json['condition'] ?? 'Unknown',
      quantity: json['quantity'] ?? 1,
    );
  }
}
