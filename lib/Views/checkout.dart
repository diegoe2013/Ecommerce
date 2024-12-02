import 'package:flutter/material.dart';
import 'package:untitled/Controllers/checkoutController.dart';
import 'package:untitled/Views/payment_methods.dart';
import 'package:untitled/Views/orderConfirmation.dart';
//import 'package:untitled/Views/shipping_address.dart';

class CheckoutScreen extends StatefulWidget {
  final double totalPrice;

  const CheckoutScreen({super.key, required this.totalPrice});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CheckoutController _checkoutController = CheckoutController();

  Map<String, dynamic> shippingAddress = {};
  Map<String, dynamic> paymentMethods = {};
  List<Map<String, dynamic>> deliveryMethods = [];
  bool isLoadingAddress = true;
  bool isLoadingPayment = true;
  bool isLoadingDeliveryMethods = true;

  Map<String, dynamic>? selectedDeliveryMethod;
  final int deliveryDays = 3; // Default delivery days

  @override
  void initState() {
    super.initState();
    _fetchShippingAddress();
    _fetchPaymentMethods();
    _fetchDeliveryMethods();
  }

  Future<void> _fetchShippingAddress() async {
    try {
      final address = await _checkoutController.fetchShippingAddress();
      setState(() {
        shippingAddress = address;
        isLoadingAddress = false;
      });
    } catch (e) {
      debugPrint('Error fetching shipping address: $e');
    }
  }

  Future<void> _fetchPaymentMethods() async {
    try {
      final payment = await _checkoutController.fetchPaymentMethods();
      setState(() {
        paymentMethods = payment;
        isLoadingPayment = false;
      });
    } catch (e) {
      debugPrint('Error fetching payment methods: $e');
    }
  }

  Future<void> _fetchDeliveryMethods() async {
    try {
      final methods = await _checkoutController.fetchDeliveryMethods();
      setState(() {
        deliveryMethods = methods;
        selectedDeliveryMethod = methods.isNotEmpty ? methods.first : null;
        isLoadingDeliveryMethods = false;
      });
    } catch (e) {
      debugPrint('Error fetching delivery methods: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliveryFee = selectedDeliveryMethod != null
        ? (selectedDeliveryMethod!['dailyFee'] * deliveryDays)
        : 0.0;

    final totalSummary = widget.totalPrice + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shipping Address Section
            const Text(
              'Shipping address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            isLoadingAddress
                ? const Center(child: CircularProgressIndicator())
                : Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                title: Text(shippingAddress['name'] ?? 'No name'),
                subtitle: Text(
                  '${shippingAddress['street'] ?? 'No street'}\n'
                      '${shippingAddress['city'] ?? 'No city'}, '
                      '${shippingAddress['country'] ?? 'No country'}',
                ),
                trailing: TextButton(
                  onPressed: () {
                  //   Navigator.push(context, MaterialPageRoute(builder: (context) => const ShippingAddress()),
                  // );
                    },
                  child: const Text(
                    'Change',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Payment Section
            const Text(
              'Payment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            isLoadingPayment
                ? const Center(child: CircularProgressIndicator())
                : Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                leading: const Icon(Icons.credit_card, color: Colors.orange),
                title: Text(
                  '**** **** **** ${paymentMethods['cardNumber']?.substring(12) ?? 'No card'}',
                ),
                subtitle: Text(paymentMethods['holderName'] ?? 'No holder'),
                trailing: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethods()),
                  );
                    },
                  child: const Text(
                    'Change',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Delivery Method Section
            const Text(
              'Delivery method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            isLoadingDeliveryMethods
                ? const Center(child: CircularProgressIndicator())
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: deliveryMethods.map((method) {
                final isSelected = selectedDeliveryMethod == method;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDeliveryMethod = method;
                    });
                  },
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange.shade100 : Colors.white,
                      border: Border.all(
                        color: isSelected ? Colors.orange : Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          method['provider'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${deliveryDays} days',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Daily Fee: \$${method['dailyFee']}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,

                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // Order Summary
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Order:', style: TextStyle(color: Colors.grey)),
                Text('\$${widget.totalPrice.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Delivery:', style: TextStyle(color: Colors.grey)),
                Text('\$${deliveryFee.toStringAsFixed(2)}'),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                'Delivery cost = shipping days × daily provider fee.',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const Divider(height: 20, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Summary:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${totalSummary.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),

            // Submit Order Button
            ElevatedButton(
              onPressed: () {
                try {
                  final deliveryFee = selectedDeliveryMethod != null
                      ? (selectedDeliveryMethod!['dailyFee'] * deliveryDays)
                      : 0.0;
                  final totalAmount = widget.totalPrice + deliveryFee;

                  // Process payment with Stripe
                   _checkoutController.processPayment(totalAmount, paymentMethods);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Pago realizado con éxito")),
                  );

                  // Redirect to success page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderConfirmationScreen(),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error en el pago: $e")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Submit order',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
