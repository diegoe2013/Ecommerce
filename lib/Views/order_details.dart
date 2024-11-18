import 'package:flutter/material.dart';
import 'package:untitled/Controllers/databaseHelper.dart';

class order_details extends StatefulWidget {
  final Map<String, dynamic> order;

  const order_details({Key? key, required this.order}) : super(key: key);

  @override
  _order_details createState() => _order_details();
}

class _order_details extends State<order_details> {
  final DBHelper dbHelper = DBHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order ${widget.order['id']}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${widget.order['createdAt'].toDate().day}/${widget.order['createdAt'].toDate().month}/${widget.order['createdAt'].toDate().year}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tracking number: ${widget.order['trackingNumber']}',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  widget.order['shippingStatus'],
                  style: TextStyle(
                      color: widget.order['shippingStatus'] == "Delivered"
                          ? Colors.green
                          : widget.order['shippingStatus'] == "Processing"
                              ? Colors.amber[800]
                              : Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${widget.order['itemCount']} items'),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.order['itemCount'],
                itemBuilder: (context, index) {
                  var itemReference = widget.order['items'][index];
                  var item = DBHelper().accessReference(itemReference);
                  return ItemCard(data: item);
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Order information',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            _buildOrderInfoRow('Shipping Address:',
                '${widget.order['deliveryAddress']['street']}, ${widget.order['deliveryAddress']['city']}, ${widget.order['deliveryAddress']['country']}'),
            const SizedBox(height: 8),
            _buildPaymentMethodRow('Payment method:',
                '**** **** **** ${widget.order['paymentMethod']['cardNumber'].toString().substring(12)}'),
            const SizedBox(height: 8),
            _buildOrderInfoRow('Delivery method:', 'FedEx, 3 days, 15\$'),
            const SizedBox(height: 8),
            _buildOrderInfoRow('Discount:', '${widget.order['discount']}%'),
            const SizedBox(height: 8),
            _buildOrderInfoRow(
              'Total Amount:',
              '\$${widget.order['totalAmount']}',
              isBold: true,
            ),
            const SizedBox(height: 16),
          ],
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

  Widget _buildOrderInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildPaymentMethodRow(String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 3,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ),
      Expanded(
          flex: 5,
          child: Row(
            children: [
              const Expanded(
                flex: 1,
                child: Icon(Icons.credit_card),
              ),
              Expanded(flex: 5, child: Text(value))
            ],
          )),
    ],
  );
}

class ItemCard extends StatelessWidget {
  final Future<Map<String, dynamic>?> data;

  const ItemCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: data,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(productData['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(productData['category'],
                      style: TextStyle(color: Colors.grey)),
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
                        Row(children: [
                          const Text('Units: TEMP',
                              style: TextStyle(color: Colors.grey)),
                          Text(productData['price'].toString(),
                              style: const TextStyle(color: Colors.black)),
                        ]),
                        Text('\$${productData['price']}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
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
