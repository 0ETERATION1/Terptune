class SpotifySong {
  final String name;
  final String artist;
  final String albumCoverUrl;
  final String songid;
  final String? previewUrl;

  SpotifySong({
    required this.name,
    required this.artist,
    required this.albumCoverUrl,
    required this.songid,
    this.previewUrl,
  });
}
