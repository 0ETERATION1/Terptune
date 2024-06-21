import 'package:flutter/material.dart';
import 'package:terptune/models/SpotifySong.dart';
import 'package:marquee/marquee.dart';
import 'package:terptune/screens/home/LikeButton.dart';
import 'package:terptune/screens/home/ReviewList.dart';

class SongDetail extends StatelessWidget {
  final SpotifySong song;

  const SongDetail({Key? key, required this.song}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 56,
          child: Marquee(
            text: '${song.name}  -  ${song.artist}',
            style: const TextStyle(
              fontSize: 24,
            ),
            blankSpace: 100,
            velocity: 50,
            pauseAfterRound: Duration(seconds: 1),
            startPadding: 10,
            accelerationDuration: Duration(seconds: 1),
            accelerationCurve: Curves.linear,
            decelerationDuration: Duration(milliseconds: 500),
            decelerationCurve: Curves.easeOut,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(song.albumCoverUrl),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${song.name}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: Text(
                            '${song.artist}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 61, 61, 61),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  LikeButton(
                    songId: song.songid,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ReviewForm(songId: song.songid),
              const SizedBox(height: 20),
              ReviewList(
                songId: song.songid,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
