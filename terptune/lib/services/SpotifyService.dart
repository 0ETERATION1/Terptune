import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terptune/main.dart';
import 'dart:convert';

import 'package:terptune/models/SpotifySong.dart';
import 'package:terptune/models/review.dart';

class SpotifyService extends StatefulWidget {
  const SpotifyService({super.key});

  static Future<SpotifySong> fetchRandomSong() async {
    final List<SpotifySong> songs = await fetchExploreSongs();
    final Random random = Random();
    return songs[random.nextInt(songs.length)];
  }

  static Future<SpotifySong> fetchSongDetails(String songId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/tracks/$songId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return SpotifySong(
        songid: data['id'],
        name: data['name'],
        artist: data['artists'][0]['name'],
        albumCoverUrl: data['album']['images'][0]['url'],
        previewUrl: data['preview_url'] ?? '',
      );
    } else {
      throw Exception('Failed to load song details');
    }
  }

  @override
  // ignore: library_private_types_in_public_api
  _SpotifyServiceState createState() => _SpotifyServiceState();

  static Future<List<SpotifySong>> fetchRecommendations() async {
    List<SpotifySong> recommendedSongs = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');

    List<Review> userReviews = await const SpotifyService().getUserReviews();

    List<String> songIds = userReviews
        .where((review) => review.rating >= 4)
        .map((review) => review.songId)
        .toList();

    List<String> seedSongIds = songIds.take(5).toList();

    final String seedTracksParameter = seedSongIds.join(',');
    //print(seedTracksParameter);
    final response = await http.get(
      Uri.parse(
        'https://api.spotify.com/v1/recommendations?limit=10&seed_tracks=$seedTracksParameter&min_popularity=70',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    //print('\n');
    //print(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> tracks = data['tracks'];

      for (var track in tracks) {
        String songName = track['name'];
        String artistName = track['artists'][0]['name'];
        String albumCoverUrl = track['album']['images'][0]['url'];
        String songId = track['id'];
        String previewUrl = track['preview_url'] ?? '';

        recommendedSongs.add(
          SpotifySong(
            name: songName,
            songid: songId,
            artist: artistName,
            albumCoverUrl: albumCoverUrl,
            previewUrl: previewUrl,
          ),
        );
      }
      return recommendedSongs;
    } else {
      throw Exception(
        'Review more songs so we can get to know you!',
      );
    }
  }

  Future<List<Review>> getUserReviews() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('uid', isEqualTo: uid)
        .get();

    List<Review> userReviews = snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Review(
        songId: data['songId'],
        rating: data['rating'],
        uid: data['uid'],
        text: data['text'],
      );
    }).toList();

    return userReviews;
  }

  static Future<List<SpotifySong>> fetchExploreSongs() async {
    List<SpotifySong> songsInfo = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/playlists/37i9dQZF1DX2L0iB23Enbq'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List<dynamic> items = data['tracks']['items'];
      for (var item in items) {
        String songId = item['track']['id'];
        String name = item['track']['name'];
        String artist = item['track']['artists'][0]['name'];
        String albumCoverUrl = item['track']['album']['images'][0]['url'];
        String previewUrl = item['track']['preview_url'] ?? '';

        // check if preview_url is null or empty string
        // do not add it to songsInfo

        //if (previewUrl == '') {
        //print("SONG WITH NO PREVIEW:::  $name");
        songsInfo.add(
          SpotifySong(
            songid: songId,
            name: name,
            artist: artist,
            albumCoverUrl: albumCoverUrl,
            previewUrl: previewUrl,
          ),
        );
        //}
      }

      return songsInfo;
    } else {
      final failresponse = fetchSpotifyData();
      File envFile = File('.env');
      List<String> lines = envFile.readAsLinesSync();

      for (int i = 0; i < lines.length; i++) {
        if (lines[i].startsWith('accesstoken=')) {
          lines[i] = 'accesstoken=$failresponse';
          break;
        }
      }

      throw Exception(
          'Your access token expired, please just refresh the tab :)');
    }
  }
}

class _SpotifyServiceState extends State<SpotifyService> {
  String? songInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Spotify API Tester"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                SpotifyService.fetchExploreSongs().then((songs) {
                  setState(() {});
                }).catchError((error) {
                  print('Error fetching songs: $error');
                });
              },
              child: const Text('Fetch Song'),
            ),
            if (songInfo != null) Text(songInfo!),
          ],
        ),
      ),
    );
  }
}
