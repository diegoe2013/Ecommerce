import 'package:flutter/material.dart';
import 'package:untitled/Controllers/favoritesController.dart';
import 'package:untitled/Controllers/bagController.dart';
import 'package:untitled/Models/favorite_item.dart';
import 'package:untitled/Models/bag_item.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesController favoritesController = FavoritesController();
  final BagController bagController = BagController();
  List<FavoriteItem> favoriteItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final items = await favoritesController.fetchFavorites();
    setState(() {
      favoriteItems = items;
      isLoading = false;
    });
  }

  Future<void> _removeFavorite(String id) async {
    await favoritesController.removeFavorite(id);
    await _loadFavorites();
  }

  Future<void> _addToBag(FavoriteItem item) async {
    final bagItem = BagItem(
      title: item.title,
      price: item.price,
      imageUrl: item.imageUrl,
      shortDescription: item.description,
      brand: item.brand,
      condition: 'New',
    );
    await bagController.addItemToBag(bagItem);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.title} added to bag!')),
    );
  }

  Widget buildFavoriteItem(FavoriteItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            item.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Color: ${item.color}'),
            Text('Size: ${item.size}'),
            Text('\$${item.price.toStringAsFixed(2)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_bag, color: Colors.orange),
              onPressed: () => _addToBag(item),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeFavorite(item.id),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Favorites',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // Search functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : favoriteItems.isEmpty
            ? const Center(
          child: Text(
            'No favorites added yet.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        )
            : ListView.builder(
          itemCount: favoriteItems.length,
          itemBuilder: (context, index) {
            return buildFavoriteItem(favoriteItems[index]);
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // "Favorites" tab
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/favorites');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/my_bag');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
