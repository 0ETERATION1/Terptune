import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:terptune/services/database.dart';

class LikeButton extends StatefulWidget {
  const LikeButton({Key? key, required this.songId}) : super(key: key);

  final String songId;

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    checkLikedStatus();
  }

  Future<void> checkLikedStatus() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userSnapshot =
        await DatabaseService(uid: uid).getUserData();
    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;

    if (userData != null && userData.containsKey('liked_songs')) {
      List<dynamic> likedSongs = userData['liked_songs'];
      setState(() {
        isLiked = likedSongs.contains(widget.songId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isLiked ? Icons.favorite : Icons.favorite_border,
        color: isLiked ? Colors.red : null,
      ),
      onPressed: () async {
        try {
          String uid = FirebaseAuth.instance.currentUser!.uid;
          if (isLiked) {
            await DatabaseService(uid: uid).removeLikedSong(widget.songId, uid);
          } else {
            await DatabaseService(uid: uid).addLikedSong(widget.songId);
          }
          setState(() {
            isLiked = !isLiked;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(isLiked
                ? "Song added to Liked Songs"
                : "Song removed from Liked Songs"),
          ));
        } catch (e) {
          print("Error updating liked status: $e");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Failed to update liked status"),
          ));
        }
      },
    );
  }
}
