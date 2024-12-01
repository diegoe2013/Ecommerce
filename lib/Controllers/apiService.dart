import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String> fetchToken() async {
  final String clientId = dotenv.get('CLIENT_ID', fallback: '');
  final String clientSecret = dotenv.get('CLIENT_SECRET_KEY', fallback: '');

  final auth = base64Encode(utf8.encode('$clientId:$clientSecret'));

  final response = await http.post(
    Uri.parse('https://api.ebay.com/identity/v1/oauth2/token'), // -> Production Enviroment
    // Uri.parse('https://api.sandbox.ebay.com/identity/v1/oauth2/token'), //-> Sandbox Enviroment Endpoint
    headers: {
      'Authorization': 'Basic $auth',
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: 'grant_type=client_credentials&scope=https://api.ebay.com/oauth/api_scope', // -> Production Enviroment
    // body: 'grant_type=client_credentials&scope=https://api.ebay.com/oauth/api_scope/buy.item.summary', // -> Sandbox
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['access_token'];
  } else {
    throw Exception('Failed to fetch token: ${response.reasonPhrase}');
  }
}