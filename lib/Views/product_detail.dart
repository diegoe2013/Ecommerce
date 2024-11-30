import 'package:flutter/material.dart';
import 'package:untitled/Controllers/apiService.dart';
import 'package:untitled/Controllers/getData.dart';

class ProductDetail extends StatefulWidget {
  final String productId;

  const ProductDetail({Key? key, required this.productId}) : super(key: key);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  Map<String, dynamic>? product;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async {
    try {
      final authToken = await fetchToken();
      final url = 'https://api.ebay.com/buy/browse/v1/item/${widget.productId}';
      final response = await getProductDetail(authToken, url);
      print("Response: $response");
      setState(() {
        product = response; // Assuming response is a Map
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching product details: $e');
    }
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
              : Padding(
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
                          onPressed: () {
                            // Logic to add product in the bag here
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Add to Bag',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
