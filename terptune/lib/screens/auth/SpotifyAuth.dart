// spotify_authentication.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SpotifyAuth {
  static final String? _clientId = dotenv.env['clientId'];
  static final String? _clientSecret = dotenv.env['clientSecret'];

  static Future<String?> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String credentials =
        base64Encode(utf8.encode('$_clientId:$_clientSecret'));
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'client_credentials',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('new access token');
      await prefs.setString('access_token', data['access_token']);
      return data['access_token'];
    } else {
      print(
          'Failed to obtain access token. Status code: ${response.statusCode}');
      return null;
    }
  }
}



// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// Future<String?> getAccessToken(String authorizationCode) async {
//   //await dotenv.load(fileName: ".env");
//   final String clientId = dotenv.env['clientId'] ?? '';
//   final String clientSecret = dotenv.env['clientSecret'] ?? '';
//   final String redirectUri = dotenv.env['redirectUri'] ?? '';

//   final response = await http.post(
//     Uri.parse('https://accounts.spotify.com/api/token'),
//     headers: {
//       'Authorization':
//           'Basic ' + base64Encode(utf8.encode('$clientId:$clientSecret')),
//       'Content-Type': 'application/x-www-form-urlencoded'
//     },
//     body: {
//       'grant_type': 'authorization_code',
//       'code': authorizationCode,
//       'redirect_uri': redirectUri,
//     },
//   );

//   if (response.statusCode == 200) {
//     final responseBody = json.decode(response.body);
//     return responseBody['access_token'];
//   } else {
//     // Handle errors or invalid responses
//     print('Request failed with status: ${response.statusCode}.');
//     return null;
//   }
// }
