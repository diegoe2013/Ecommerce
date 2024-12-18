import 'package:flutter/material.dart';
import 'package:untitled/Controllers/databaseHelper.dart';
import 'package:untitled/Controllers/apiService.dart';
import 'package:untitled/Controllers/getData.dart';
import 'package:untitled/Controllers/bagController.dart';
import 'package:untitled/Controllers/favoritesController.dart';
import 'package:untitled/Models/bag_item.dart';
import 'package:untitled/Models/favorite_item.dart';
import 'write_review.dart';

class ProductDetail extends StatefulWidget {

  final String productId;
  final List<dynamic> productList;

  const ProductDetail({Key? key, required this.productId, required this.productList}) : super(key: key);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final FavoritesController favoritesController = FavoritesController();
  final DBHelper dbHelper = DBHelper();
  Map<String, dynamic>? product;
  bool isLoading = true;
  List<Map<String, dynamic>> reviews = [];
  double averageRating = 0.0;
  bool isReviewsLoading = true;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
    checkIfFavorite();
  }

  Future<void> fetchProductDetails() async {
    try {
      final authToken = await fetchToken();
      final url = 'https://api.ebay.com/buy/browse/v1/item/${widget.productId}';
      final response = await getProductDetail(authToken, url); // Ensure this function exists

      setState(() {
        product = response;
        print("Product: $product");
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching product details: $e');
    }
  }

  Future<void> checkIfFavorite() async {
    if (product == null) return;

    final favorites = await favoritesController.fetchFavorites();
    setState(() {
      isFavorite = favorites.any((fav) => fav.title == product!['title']);
    });
  }

  Future<void> toggleFavorite() async {
    if (product == null) return;

    if (isFavorite) {
      // Remove from favorites
      final favorites = await favoritesController.fetchFavorites();
      final favorite = favorites.firstWhere((fav) => fav.title == product!['title']);
      await favoritesController.removeFavorite(favorite.id);
    } else {
      // Add to favorites
      final favoriteItem = FavoriteItem(
        title: product!['title'],
        price: double.tryParse(product!['price']['value'].toString()) ?? 0.0,
        imageUrl: product!['image']['imageUrl'],
        description: product!['shortDescription'] ?? 'No Description',
        brand: product!['brand'] ?? 'No Brand',
        color: 'Unknown',
        size: 'Unknown',
      );
      await favoritesController.addFavorite(favoriteItem);
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Back'),
        backgroundColor: Colors.orange,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : product == null
              ? const Center(
                  child: Text('Error loading product details'),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image
                        Center(
                          child: product!['image'] != null &&
                                  product!['image']['imageUrl'] != null
                              ? Image.network(
                                  product!['image']['imageUrl'],
                                  height: 200,
                                  width: 200,
                                  fit: BoxFit.cover,
                                )
                              : const Text("No Image"),
                        ),
                        const SizedBox(height: 16),
                        // Product Title and Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                product!['title'] ?? 'No Title',
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Color.fromARGB(134, 0, 0, 0),
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Text(
                              product!['price'] != null && product!['price']['value'] != null
                                  ? '\$${product!['price']['value']}'
                                  : 'No Price',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color.fromARGB(134, 0, 0, 0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        //Product Description
                        Text(
                          product!['shortDescription'] ?? 'No description available',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        // Add to Bag Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              // Simula la lógica de agregar a la bolsa
                              final bagItem = BagItem(
                                title: product!['title'],
                                price: double.tryParse(product!['price']['value'].toString()) ?? 0.0,
                                imageUrl: product!['image']['imageUrl'],
                                shortDescription: product!['shortDescription'] ?? 'No Description',
                                brand: product!['brand'] ?? 'No Brand',
                                condition: product!['condition'] ?? 'No Condition',
                              );
                              await BagController().addItemToBag(bagItem);

                              // Muestra un dialog con un check al agregar
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  Future.delayed(const Duration(seconds: 1), () {
                                    Navigator.of(context).pop(); // Cierra el dialog automáticamente
                                  });

                                  return AlertDialog(
                                    alignment: Alignment.center,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.check_circle, color: Colors.green, size: 50),
                                        SizedBox(height: 10),
                                        Text(
                                          'Added to Bag!',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Add to Bag',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),


                        // Favorite Icon
                        Positioned(
                          top: 16,
                          right: 16,
                          child: IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                              size: 30
                            ),
                            onPressed: toggleFavorite,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Details...
                            const SizedBox(height: 16),
                            const Text(
                              "Ratings & Reviews",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                             dbHelper.getData(
                                    path: "reviews",
                                    columnFilter: 'productId',
                                    filterValue: widget.productId.toString(),
                                    itemBuilder: (reviews) {
                                      print("Review: $reviews");
                                      if (reviews.isEmpty) {
                                        return const Text("No reviews available.");
                                      }

                                      double averageRating = 0;
                                      for (var review in reviews) {
                                        averageRating += review['rating'] ?? 0;
                                      }
                                      averageRating /= reviews.length;

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "$averageRating",
                                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Display Star Ratings
                                                  Row(
                                                    children: List.generate(
                                                      5,
                                                      (index) => Icon(
                                                        Icons.star,
                                                        color: index < averageRating
                                                            ? Colors.orange
                                                            : Colors.grey.shade300,
                                                        size: 24,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    "${reviews.length} reviews",
                                                    style: const TextStyle(fontSize: 16),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const Divider(),
                                          ...reviews.map((review) {
                                            return ListTile(
                                              leading: CircleAvatar(
                                                backgroundImage: review['userImage'] != null
                                                    ? NetworkImage(review['userImage'])
                                                    : null,
                                                child: review['userImage'] == null
                                                    ? const Icon(Icons.person)
                                                    : null,
                                              ),
                                              // title: Text(review['username']),
                                              title: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: List.generate(
                                                      5,
                                                      (index) => Icon(
                                                        Icons.star,
                                                        color: index < review['rating']
                                                            ? Colors.orange
                                                            : Colors.grey.shade300,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(review['comment'] ?? 'No comment available'),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      );
                                    },
                                  ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to Write Review screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WriteReview(productId: widget.productId, productList: widget.productList,),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                              child: const Text("Write a Review"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Top Offers Section
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "You can also like this",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Top Offers Product List
                        SizedBox(
                          height: 300,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.productList.isEmpty ? 0 : widget.productList.length,
                            itemBuilder: (context, index) {
                              return ProductCard(product: widget.productList[index], productList: widget.productList);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/favorites');
          }
          if (index == 2) {
            Navigator.pushNamed(context, '/my_bag');
          }
          if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'My Bag',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final List<dynamic> productList;

  const ProductCard({Key? key, required this.product, required this.productList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetail(productId: product['itemId'], productList: productList), // Pass the correct data to ProductDetail
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: product['image'] != null && product['image']['imageUrl'] != null ? DecorationImage(
                  image: NetworkImage(product['image']['imageUrl']),
                  fit: BoxFit.cover,
                ) : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product['price']['value']}',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
