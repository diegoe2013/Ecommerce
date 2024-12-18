import 'package:flutter/material.dart';
import 'package:untitled/Controllers/bagController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/Models/bag_item.dart';
import 'package:untitled/Views/checkout.dart';

class MyBag extends StatefulWidget {
  const MyBag({super.key});

  @override
  _MyBagState createState() => _MyBagState();
}

class _MyBagState extends State<MyBag> {
  final BagController bagController = BagController();
  final TextEditingController promoCodeController = TextEditingController();
  String promoCodeError = '';
  String appliedPromoCode = '';
  double discountPercentage = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBagData();
  }

  Future<void> _fetchBagData() async {
    await bagController.fetchBag();
    setState(() {
      isLoading = false;
      appliedPromoCode = ''; // Reset promo code on fetch
    });
  }

  Future<void> _applyPromoCode() async {
    final promoCode = promoCodeController.text.trim();

    if (promoCode.isEmpty) {
      setState(() {
        promoCodeError = 'Promo code cannot be empty.';
      });
      return;
    }

    try {
      await bagController.addPromoCode(promoCode);

      final promoDoc = await FirebaseFirestore.instance
          .collection('global_promoCodes')
          .where('code', isEqualTo: promoCode)
          .get();

      if (promoDoc.docs.isNotEmpty) {
        final promoData = promoDoc.docs.first.data();
        discountPercentage = (promoData['%discount'] ?? 0.0) * 100; // Convert to %
      }

      setState(() {
        promoCodeError = '';
        appliedPromoCode = promoCode;
      });
    } catch (e) {
      setState(() {
        promoCodeError = 'Invalid promo code.';
      });
    }
  }

  Future<void> _removePromoCode() async {
    try {
      await bagController.removePromoCode();

      setState(() {
        appliedPromoCode = '';
        discountPercentage = 0.0;
        promoCodeController.clear();
      });

      // Refresh data
      await _fetchBagData();
    } catch (e) {
      debugPrint('Error removing promo code: $e');
    }
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: bagController.bagItems.length,
                itemBuilder: (context, index) {
                  final BagItem product = bagController.bagItems[index];
                  return buildCartItem(product);
                },
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: promoCodeController,
              decoration: InputDecoration(
                hintText: 'Enter your promo code',
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: GestureDetector(
                  onTap: _applyPromoCode,
                  child: Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Icon(Icons.arrow_forward,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            if (promoCodeError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  promoCodeError,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),
            if (appliedPromoCode.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Promo Code: $appliedPromoCode ($discountPercentage%)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle,
                          color: Colors.red),
                      onPressed: _removePromoCode,
                    ),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total amount:',
                    style: TextStyle(fontSize: 16)),
                Text(
                  '\$${bagController.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutScreen(
                        totalPrice: bagController.totalPrice),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Checkout',
                  style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/favorites');
          }
          if (index == 2) {
            Navigator.pushNamed(context, '/my_bag');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          } else if (index == 0) {
            Navigator.pushNamed(context, '/home');
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
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Color: Example Color',
                      style: const TextStyle(color: Colors.grey)),
                  Text('Size: Example Size',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: product.quantity > 1
                            ? Colors.orange
                            : Colors.grey,
                      ),
                      onPressed: product.quantity > 1
                          ? () async {
                        await bagController.updateItemQuantity(
                          product.id,
                          product.quantity - 1,
                        );
                        setState(() {});
                      }
                          : null,
                    ),
                    Text(
                      '${product.quantity}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline,
                          color: Colors.orange),
                      onPressed: () async {
                        await bagController.updateItemQuantity(
                          product.id,
                          product.quantity + 1,
                        );
                        setState(() {});
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await bagController.removeItemFromBag(product.id);
                        setState(() {});
                      },
                    ),
                  ],
                ),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
