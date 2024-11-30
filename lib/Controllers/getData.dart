import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> getData(String token, String url) async {
  print('Fetching products');

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    print('Products fetched successfully.');
    return body['itemSummaries'] ?? [];
  } else {
    print('Failed to fetch products. Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    throw Exception('Failed to fetch products: ${response.statusCode}');
  }
}