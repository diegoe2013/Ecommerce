import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;

const String stripeSecretKey = 'sk_test_51QRRS7DjvqEatelqPJ75h1tt61ipzvhbDULjCLvL8dj4BiHpULIFs27jsakJRU3AIpN3mdptSOhbKjIEpVY2QLWD008eAHxHLq';

void startServer() async {
  final router = Router()
    ..post('/create-payment-intent', _createPaymentIntent);

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_corsMiddleware)
      .addHandler(router);

  final server = await io.serve(handler, 'localhost', 8080);
  print('Servidor escuchando en http://${server.address.host}:${server.port}');
}

Middleware get _corsMiddleware => createMiddleware(
  responseHandler: (Response response) => response.change(
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': '*',
      'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
    },
  ),
);

Future<Response> _createPaymentIntent(Request request) async {
  try {
    final body = await request.readAsString();
    final data = json.decode(body);

    final int amount = data['amount'];
    final String currency = data['currency'];

    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Authorization': 'Bearer $stripeSecretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'amount': amount.toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return Response.ok(json.encode({
        'clientSecret': responseData['client_secret'],
      }));
    } else {
      return Response.internalServerError(
          body: 'Error al crear el PaymentIntent: ${response.body}');
    }
  } catch (e) {
    return Response.internalServerError(
        body: 'Error en el servidor: ${e.toString()}');
  }
}
