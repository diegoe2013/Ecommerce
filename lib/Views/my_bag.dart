import 'package:flutter/material.dart';
import 'package:untitled/Controllers/bagController.dart';
import 'package:untitled/Models/bag_item.dart';

class MyBag extends StatefulWidget {
  const MyBag({super.key});

  @override
  _MyBagState createState() => _MyBagState();
}

class _MyBagState extends State<MyBag> {
  final BagController _bagController = BagController();
  bool isLoading = true;
  final String userId = "10"; // Replace with the logged user ID

  @override
  void initState() {
    super.initState();
    _loadBagItems();
  }

  Future<void> _loadBagItems() async {
    await _bagController.fetchBag(userId);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Bag',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: _bagController.bagItems.isEmpty
            ? const Center(child: Text('Your bag is empty.'))
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _bagController.bagItems.length,
                itemBuilder: (context, index) {
                  final product = _bagController.bagItems[index];
                  return buildCartItem(product);
                },
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter your promo code',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total amount:', style: TextStyle(fontSize: 16)),
                Text(
                  '${_bagController.totalPrice.toStringAsFixed(2)}\$',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Checkout logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Checkout', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCartItem(BagItem product) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                product.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Condition: ${product.condition}',
                      style: const TextStyle(color: Colors.grey)),
                  Text('Brand: ${product.brand}', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        if (product.quantity > 1) {
                          _bagController
                              .updateItemQuantity(userId, product.id, product.quantity - 1)
                              .then((_) => setState(() {}));
                        }
                      },
                    ),
                    Text('${product.quantity}', style: const TextStyle(fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        _bagController
                            .updateItemQuantity(userId, product.id, product.quantity + 1)
                            .then((_) => setState(() {}));
                      },
                    ),
                  ],
                ),
                Text('${product.price}\$', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            PopupMenuButton(
              onSelected: (value) {
                if (value == 'delete') {
                  _bagController.removeItemFromBag(userId, product.id).then((_) {
                    setState(() {});
                  });
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Remove from bag'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
