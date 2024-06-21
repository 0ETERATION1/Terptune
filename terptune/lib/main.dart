import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:terptune/models/users.dart';
import 'package:terptune/providers/audio_player_provider';
import 'package:terptune/screens/wrapper.dart';
import 'package:terptune/services/auth.dart';
import 'package:terptune/screens/auth/SpotifyAuth.dart';
//import 'spotify_authentication.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:terptune/screens/auth/SpotifyAuth.dart';

// ...
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<Users?>.value(
      value: AuthService().user,
      initialData: null,
      catchError: (_, __) {},
      child: MaterialApp(
        title: 'TerpTune',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          textTheme: Theme.of(context).textTheme.copyWith(
                headline6: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
        ),
        home: const Wrapper(),
      ),
    );
  }
}

Future<String?> fetchSpotifyData() async {
  String? accessToken = await SpotifyAuth.getAccessToken();
  if (accessToken != null) {
    print('Spotify Access Token: $accessToken');
    return accessToken;
  } else {
    print('Failed to obtain Spotify access token.');
    return null;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //print("Current working directory: ${Directory.current.path}");

  try {
    print("Attempting to load .env file...");
    await dotenv.load(fileName: '.env');
    print("Successfully loaded .env file");
    // '/Users/sasha/Desktop/UMDSTUFF/CMSC436/nextbigthing/terptune/.env');
  } catch (e) {
    print("Error loading .env file: $e");
  }

  final file = File('.env');

  String? testValue = dotenv.env['clientId'];

  print("The value of clientId is: $testValue");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      // need to add the provider
      create: (context) => AudioPlayerProvider(),
      child: const MyApp(),
    ),
  );
  fetchSpotifyData();
}
