import 'package:flutter/material.dart';

class ProductDetail extends StatelessWidget {
  final Map product;

  const ProductDetail({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Back'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Center(
              child: product['image'] != null && product['image']['imageUrl'] != null ? Image.network(
                product['image']['imageUrl'],
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ) : Text("No Image"),
            ),
            const SizedBox(height: 16),
            Row(
              // Product Title and price
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product['title'],
                      style: const TextStyle(fontSize: 22, color: Color.fromARGB(134, 0, 0, 0), fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Text(
                    '\$${product['price']['value']}',
                    style: const TextStyle(fontSize: 20, color: Color.fromARGB(134, 0, 0, 0), fontWeight: FontWeight.bold),
                  ),
                ],
            ),
            // const SizedBox(height: 16),
            // // Product Description
            // Text(
            //   product['description'],
            //   style: const TextStyle(fontSize: 16),
            // ),
            const SizedBox(height: 16),
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
