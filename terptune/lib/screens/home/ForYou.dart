import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terptune/models/SpotifySong.dart';
import 'package:terptune/providers/audio_player_provider';
import 'package:terptune/screens/home/SongDetail.dart';
import 'package:terptune/services/SpotifyService.dart';
import 'package:audioplayers/audioplayers.dart';

class ForYou extends StatefulWidget {
  @override
  _ForYouState createState() => _ForYouState();
}

class _ForYouState extends State<ForYou> {
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SpotifySong>>(
      future: SpotifyService.fetchRecommendations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Please review more songs so we can get to know you!'),
          );
        } else {
          final List<SpotifySong> songsInfo = snapshot.data ?? [];
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                title: Text(
                  'Based on what you enjoy',
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
                  (BuildContext context, int index) {
                    final SpotifySong song = songsInfo[index];

                    // seeing if song is currently playing
                    bool isActiveSong =
                        Provider.of<AudioPlayerProvider>(context)
                                .currentPlayingUrl ==
                            song.previewUrl;
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: ListTile(
                        leading: Image.network(song.albumCoverUrl),
                        title: Text(
                          '${song.name}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${song.artist}',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        trailing: song.previewUrl != null &&
                                song.previewUrl!.isNotEmpty
                            ? IconButton(
                                icon: Icon(isActiveSong &&
                                        Provider.of<AudioPlayerProvider>(
                                                context)
                                            .isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow),
                                onPressed: () {
                                  if (isActiveSong &&
                                      Provider.of<AudioPlayerProvider>(context,
                                              listen: false)
                                          .isPlaying) {
                                    Provider.of<AudioPlayerProvider>(context,
                                            listen: false)
                                        .pauseSong();
                                  } else {
                                    Provider.of<AudioPlayerProvider>(context,
                                            listen: false)
                                        .playSong(song.previewUrl!);
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
                      ),
                    );
                  },
                  childCount: songsInfo.length,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Future<void> _playSong(String previewUrl) async {
    await _audioPlayer.stop();

    await _audioPlayer.play(UrlSource(previewUrl));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
