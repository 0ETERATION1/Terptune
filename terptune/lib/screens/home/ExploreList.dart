import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:terptune/models/SpotifySong.dart';
import 'package:terptune/providers/audio_player_provider';
import 'package:terptune/screens/home/ReviewList.dart';
import 'package:terptune/screens/home/SongDetail.dart';
import 'package:terptune/services/SpotifyService.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shake/shake.dart';

class ExploreList extends StatefulWidget {
  const ExploreList({Key? key}) : super(key: key);

  @override
  _ExploreListState createState() => _ExploreListState();
}

class _ExploreListState extends State<ExploreList> {
  late final AudioPlayer _audioPlayer;
  bool isPlaying = false;
  String? currentPlayingUrl;
  late ShakeDetector detector;
  bool isAlertDialogOpen = false;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initShakeDetector();
  }

  void _initShakeDetector() {
    detector = ShakeDetector.autoStart(
      onPhoneShake: () async {
        if (!isAlertDialogOpen) {
          final SpotifySong randomSong = await SpotifyService.fetchRandomSong();
          _playSong(randomSong.previewUrl!);
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              isAlertDialogOpen = true;
              return AlertDialog(
                title: Text(randomSong.name),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Artist: ${randomSong.artist}'),
                      Image.network(randomSong.albumCoverUrl),
                      ReviewForm(songId: randomSong.songid),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _pauseSong();
                    },
                    child: Text('Close'),
                  ),
                ],
              );
            },
          ).then((_) {
            isAlertDialogOpen = false;
          });
        }
      },
      shakeThresholdGravity: 2.7,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
    );
  }

  @override
  void dispose() {
    detector.stopListening();
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildSongListItem(BuildContext context, SpotifySong song) {
    return Consumer<AudioPlayerProvider>(
        builder: (context, audioPlayerProvider, child) {
      bool isActiveSong =
          audioPlayerProvider.currentPlayingUrl == song.previewUrl;
      bool isPlaying = isActiveSong && audioPlayerProvider.isPlaying;

      return ListTile(
        leading: CachedNetworkImage(
          imageUrl: song.albumCoverUrl,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        title: Text(
          song.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.ubuntu().fontFamily,
          ),
        ),
        subtitle: Text(
          song.artist,
          style: TextStyle(
            fontSize: 14,
            fontFamily: GoogleFonts.ubuntu().fontFamily,
          ),
        ),
        trailing: song.previewUrl != null && song.previewUrl!.isNotEmpty
            ? IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  if (isPlaying) {
                    audioPlayerProvider.pauseSong();
                  } else {
                    audioPlayerProvider.playSong(song.previewUrl!);
                  }
                },
              )
            : const Text('No Preview'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SongDetail(song: song),
            ),
          );
        },
      );
    });
  }

  /*
  THE OLD WIDGET
  */

  // Widget _buildSongListItem(SpotifySong song) {
  //   bool isActiveSong = currentPlayingUrl == song.previewUrl;

  //   return ListTile(
  //     leading: CachedNetworkImage(
  //       imageUrl: song.albumCoverUrl,
  //       placeholder: (context, url) => CircularProgressIndicator(),
  //       errorWidget: (context, url, error) => Icon(Icons.error),
  //     ),
  //     title: Text(
  //       song.name,
  //       style: TextStyle(
  //         fontSize: 16,
  //         fontWeight: FontWeight.bold,
  //         fontFamily: GoogleFonts.ubuntu().fontFamily,
  //       ),
  //     ),
  //     subtitle: Text(
  //       song.artist,
  //       style: TextStyle(
  //         fontSize: 14,
  //         fontFamily: GoogleFonts.ubuntu().fontFamily,
  //       ),
  //     ),
  //     trailing: song.previewUrl != null && song.previewUrl!.isNotEmpty
  //         ? IconButton(
  //             icon: Icon(
  //                 isActiveSong && isPlaying ? Icons.pause : Icons.play_arrow),
  //             onPressed: () {
  //               if (isActiveSong && isPlaying) {
  //                 _pauseSong();
  //               } else {
  //                 _playSong(song.previewUrl!);
  //               }
  //             },
  //           )
  //         : const Text('No Preview'),
  //     onTap: () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => SongDetail(song: song),
  //         ),
  //       );
  //     },
  //   );
  // }

  Future<void> _playSong(String previewUrl) async {
    if (currentPlayingUrl != previewUrl) {
      await _audioPlayer.stop();
      await _audioPlayer.setSourceUrl(previewUrl);
      currentPlayingUrl = previewUrl;
    }
    await _audioPlayer.resume();
    if (!isPlaying) {
      setState(() {
        isPlaying = true;
      });
    }
  }

  Future<void> likeSong() async {
    setState(() {
      isLiked = !isLiked;
    });
  }

  Future<void> _pauseSong() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SpotifySong>>(
      future: SpotifyService.fetchExploreSongs(),
      builder: (context, snapshot) {
        // FILE NOT FOUND ERROR BEING CAUSED HERE!!!

        if (snapshot.hasError) {
          return Center(
              child: Text(
                  'Hey! Your access token expired. Please hot restart or refresh the tab by going to a different tab and coming back, thanks!! '));

          //return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final List<SpotifySong> songsInfo = snapshot.data ?? [];
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                title: Text(
                  'Browse the most popular music out now',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          const Color.fromARGB(255, 133, 87, 161)!,
                          const Color.fromARGB(255, 110, 61, 118)!,
                          const Color.fromARGB(255, 152, 143, 143)!,
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: songsInfo.length,
                  (BuildContext context, int index) {
                    // added context to function call
                    return _buildSongListItem(context, songsInfo[index]);
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
