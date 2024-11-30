import 'package:flutter/material.dart';
import 'package:untitled/Controllers/apiService.dart';
import 'package:untitled/Controllers/getData.dart';

class ProductDetail extends StatefulWidget {
  final String productId;
  // final List<Map<String, dynamic>> productsList;
  final List<dynamic> productList; 

  const ProductDetail({Key? key, required this.productId, required this.productList}) : super(key: key);

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
      final response = await getProductDetail(authToken, url); // Ensure this function exists

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
                        const SizedBox(height: 16),
                        // Top Offers Section
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
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
