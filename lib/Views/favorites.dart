import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:untitled/Controllers/databaseHelper.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  _Favorites createState() => _Favorites();
}

class _Favorites extends State<Favorites> {
  final DBHelper dbHelper = DBHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Expanded(
          child: dbHelper.getData(
              path: 'users',
              columnFilter: 'name',
              filterValue: 'Diego Encarnación',
              itemBuilder: (users) {
                var user = users[0];
                var favorites = user['favorites'] as List<dynamic>;

                if (favorites.isEmpty) {
                  return const Center(child: Text('No favorites.'));
                }
                return ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    print("FAVORITES");
                    var favoriteReference = favorites[index];
                    var favorite =
                        DBHelper().accessReference(favoriteReference);

                    return ProductCard(product: favorite);
                  },
                );
              }),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () {},
              child:
                  const Text('Reorder', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
              ),
              child: const Text('Leave feedback',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Future<Map<String, dynamic>?> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: product,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          Map<String, dynamic> productData = snapshot.data!;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(productData['category'],
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(productData['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Text('Color: ',
                            style: TextStyle(color: Colors.grey)),
                        Text(productData['attributes']['color'],
                            style: const TextStyle(color: Colors.black)),
                      ]),
                      Row(children: [
                        const Text('Material: ',
                            style: TextStyle(color: Colors.grey)),
                        Text(productData['attributes']['material'],
                            style: const TextStyle(color: Colors.black)),
                      ])
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('\$${productData['price']}'),
                        RatingBarIndicator(
                          rating: productData['ratings'].toDouble(),
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 20.0,
                        ),
                      ]),
                ],
              ),
            ),
          );
        } else {
          return const Text('No data found.');
        }
      },
    );
  }
}
