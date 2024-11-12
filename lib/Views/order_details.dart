import 'package:flutter/material.dart';

class order_details extends StatefulWidget {
  final Map<String, dynamic> order;

  const order_details({Key? key, required this.order}) : super(key: key);

  @override
  _order_details createState() => _order_details();
}

class _order_details extends State<order_details> {
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
                  '10/10/10', //Text('${widget.order['createdAt'].toDate().day}/${widget.order['createdAt'].toDate().month}/${widget.order['createdAt'].toDate().year}',
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
                itemCount: widget.order['items'].length,
                itemBuilder: (context, index) {
                  var item = widget.order['items'][index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Image.network(
                            item['imageUrl'],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Color: ${item['color']}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  'Size: ${item['size']}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  'Units: ${item['units']}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${item['price']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
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
                '${widget.order['deliveryAdress']['street']}, ${widget.order['deliveryAdress']['city']}, ${widget.order['deliveryAdress']['state']}'),
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
