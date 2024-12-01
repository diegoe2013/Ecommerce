import 'package:flutter/material.dart';
import 'package:untitled/Controllers/databaseHelper.dart';
import 'product_detail.dart';

class WriteReview extends StatelessWidget {
  final String productId;
  final List<dynamic> productList; 

  const WriteReview({Key? key, required this.productId, required this.productList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController commentController = TextEditingController();
    double rating = 0;
    late String autoincrementIndex;
    final DBHelper dbHelper = DBHelper();


    return Scaffold(
      appBar: AppBar(
        title: const Text("Write a Review"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Rate the product",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: List.generate(
                5,
                (index) => IconButton(
                  onPressed: () {
                    rating = index + 1.0;
                  },
                  icon: Icon(
                    Icons.star,
                    color: index < rating ? Colors.orange : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Your Review",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Write your review...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                autoincrementIndex = await dbHelper.autoIncrement('reviews');

                final reviewData = {
                  "id": autoincrementIndex,
                  "createdAt": DateTime.now().toIso8601String(),
                  "productId": productId.toString(),
                  "comment": commentController.text.toString(),
                  "rating": rating
                };
                
                await dbHelper.addData("reviews/$autoincrementIndex", reviewData);

                // Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetail(
                      productId: productId,
                      productList: productList,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
