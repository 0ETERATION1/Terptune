import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:terptune/models/SpotifySong.dart';
import 'package:terptune/models/review.dart';

class DatabaseService {
  final String uid;

  DatabaseService({required this.uid});

  // collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  Future updateUserData(String name, String email) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'email': email,
      'liked_songs': [],
    });
  }

  Future<void> removeLikedSong(String songId, String uid) async {
    DocumentReference userRef = userCollection.doc(uid);

    DocumentSnapshot userSnapshot = await userRef.get();
    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;

    if (userData != null && userData.containsKey('liked_songs')) {
      List<dynamic> likedSongs = List.from(userData['liked_songs']);
      likedSongs.remove(songId);

      await userRef.update({
        'liked_songs': likedSongs,
      });
    }
  }

  Future<void> addLikedSong(String songId) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(uid);

      await userRef.update({
        'liked_songs': FieldValue.arrayUnion([songId]),
      });
    } catch (e) {
      print("Error adding liked song: $e");
      throw Exception("Error adding liked song: $e");
    }
  }

  Future<void> addReview(Review review) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    DocumentReference reviewRef =
        FirebaseFirestore.instance.collection('reviews').doc();

    batch.set(reviewRef, {
      'uid': review.uid,
      'songId': review.songId,
      'text': review.text,
      'rating': review.rating,
      'timestamp': FieldValue.serverTimestamp(),
    });

    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(review.uid);

    batch.update(userRef, {'reviewCount': FieldValue.increment(1)});

    await batch.commit().catchError((error) {
      print("Failed to add review and update review count: $error");
      throw Exception("Error adding review: $error");
    });
  }

 

  Future<DocumentSnapshot> getUserData() async {
    return await userCollection.doc(uid).get();
  }
}
