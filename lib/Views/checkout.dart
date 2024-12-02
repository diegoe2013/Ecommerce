import 'package:flutter/material.dart';
import 'package:untitled/Controllers/checkoutController.dart';

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
                  onPressed: () {},
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
                  onPressed: () {},
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
                : Column(
              children: deliveryMethods
                  .map((method) => RadioListTile<Map<String, dynamic>>(
                value: method,
                groupValue: selectedDeliveryMethod,
                onChanged: (value) {
                  setState(() {
                    selectedDeliveryMethod = value;
                  });
                },
                title: Text(method['provider']),
                subtitle: Text('Daily fee: \$${method['dailyFee']}'),
              ))
                  .toList(),
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
                // Lógica de confirmación de pedido
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
