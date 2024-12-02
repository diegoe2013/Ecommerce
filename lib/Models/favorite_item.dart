import 'package:uuid/uuid.dart';

class FavoriteItem {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  final String description;
  final String brand;
  final String color;
  final String size;

  FavoriteItem({
    String? id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.brand,
    required this.color,
    required this.size,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'brand': brand,
      'color': color,
      'size': size,
    };
  }

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'] ?? const Uuid().v4(),
      title: json['title'] ?? 'No Title',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? 'No description',
      brand: json['brand'] ?? 'Unknown',
      color: json['color'] ?? 'Unknown',
      size: json['size'] ?? 'Unknown',
    );
  }
}
