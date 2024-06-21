import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:terptune/models/SpotifySong.dart';
import 'package:terptune/screens/home/utils.dart';
import 'package:terptune/services/SpotifyService.dart';
import 'package:terptune/services/database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:terptune/services/add_data.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final String? currentUserId = currentUser?.uid;
    return FutureBuilder<DocumentSnapshot>(
      future: currentUserId != null
          ? DatabaseService(uid: currentUserId!).getUserData()
          : null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data == null) {
          return const Text('No data found');
        } else {
          var userData = snapshot.data!.data() as Map<String, dynamic>?;
          if (userData == null) {
            return const Text('No user data found');
          }
          var userName2 = userData['name'];

          return Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 165,
                  child: _TopPortion(),
                ),
                // Expanded(child: // Remove or adjust this line
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        userName2,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                //), // Remove or adjust this line
                _ProfileInfoRow(userId: currentUserId!),
                RecentReviews(userId: currentUserId),
              ],
            ),
          );
        }
      },
    );
  }
}

class LikedSongs extends StatefulWidget {
  final String userId;

  const LikedSongs({Key? key, required this.userId});

  @override
  _LikedSongsState createState() => _LikedSongsState();
}

class _LikedSongsState extends State<LikedSongs> {
  Future<List<SpotifySong>> fetchLikedSongs() async {
    var userDataSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    var likedSongsIds = userDataSnapshot.data()?['liked_songs'] ?? [];
    List<SpotifySong> likedSongs = [];
    for (var songId in likedSongsIds) {
      var song = await SpotifyService.fetchSongDetails(songId);
      likedSongs.add(song);
    }
    return likedSongs;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SpotifySong>>(
      future: fetchLikedSongs(),
      builder:
          (BuildContext context, AsyncSnapshot<List<SpotifySong>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error.toString()}');
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const Text('No liked songs');
        }

        return Expanded(
          child: ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var song = snapshot.data![index];
              return ListTile(
                leading:
                    Image.network(song.albumCoverUrl, width: 50, height: 50),
                title: Text(song.name, overflow: TextOverflow.ellipsis),
                subtitle: Text(song.artist, overflow: TextOverflow.ellipsis),
              );
            },
          ),
        );
      },
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final String userId;

  const _ProfileInfoRow({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.hasError) {
          return const Text("Error: Unable to load user data");
        }

        Map<String, dynamic> userData =
            snapshot.data!.data() as Map<String, dynamic> ?? {};
        int reviewCount = userData['reviewCount'] ?? 0;

        return Center(
          child: Text(
            "You've left $reviewCount reviews!",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        );
      },
    );
  }
}

class RecentReviews extends StatefulWidget {
  final String userId;

  const RecentReviews({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _RecentReviewsState createState() => _RecentReviewsState();
}

class _RecentReviewsState extends State<RecentReviews> {
  Future<List<Map<String, dynamic>>> fetchReviewsWithSongs() async {
    var reviewsQuery = await FirebaseFirestore.instance
        .collection('reviews')
        .where('uid', isEqualTo: widget.userId)
        .orderBy('timestamp', descending: true)
        .get();

    var reviewsWithSongsFutures = reviewsQuery.docs.map((reviewDoc) async {
      var reviewData = reviewDoc.data();
      SpotifySong song =
          await SpotifyService.fetchSongDetails(reviewData['songId']);
      return {
        'review': reviewData,
        'song': song,
      };
    }).toList();

    var reviewsWithSongs = await Future.wait(reviewsWithSongsFutures);
    return reviewsWithSongs;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchReviewsWithSongs(),
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error.toString()}');
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const Text('No recent reviews');
        }

        return Expanded(
          child: ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var reviewWithSong = snapshot.data![index];
              var review = reviewWithSong['review'] as Map<String, dynamic>;
              var song = reviewWithSong['song'] as SpotifySong;
              return ListTile(
                leading:
                    Image.network(song.albumCoverUrl, width: 50, height: 50),
                title: Text(song.name, overflow: TextOverflow.ellipsis),
                subtitle: Text("${review['rating']} - ${review['text']}",
                    overflow: TextOverflow.ellipsis),
              );
            },
          ),
        );
      },
    );
  }
}

class ProfileInfoItem {
  final String title;
  final int value;
  const ProfileInfoItem(this.title, this.value);
}

class _TopPortion extends StatefulWidget {
  const _TopPortion();

  @override
  _TopPortionState createState() => _TopPortionState();
}

class _TopPortionState extends State<_TopPortion> {
  String profileImageUrl = "";
  Uint8List? image2;

  @override
  void initState() {
    super.initState();
    fetchProfileImage();
  }

  void fetchProfileImage() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .get();

    setState(() {
      profileImageUrl = userDoc['profileImage'];
    });
  }

  final currentUser = FirebaseAuth.instance.currentUser;
  void saveProfile() async {
    String res =
        await StoreData().saveData(file: image2!, uid: currentUser!.uid);
    setState(() {
      profileImageUrl = res;
    });
  }

  void selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Uint8List img = await pickedFile.readAsBytes();

      String imageUrl =
          await StoreData().saveData(file: img, uid: currentUser!.uid);
      setState(() {
        profileImageUrl = imageUrl;
      });
    } else {
      print("No image selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 50),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color.fromARGB(255, 168, 128, 236),
                Color.fromARGB(255, 194, 167, 241)
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircleAvatar(
                radius: 64,
                backgroundImage: profileImageUrl.isNotEmpty
                    ? NetworkImage(profileImageUrl)
                    : NetworkImage(
                            'https://png.pngitem.com/pimgs/s/421-4212266_transparent-default-avatar-png-default-avatar-images-png.png')
                        as ImageProvider,
              ),
              Positioned(
                bottom: -10,
                left: 80,
                child: IconButton(
                  onPressed: selectImage,
                  icon: const Icon(Icons.add_a_photo),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
