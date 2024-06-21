import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:terptune/models/review.dart';
import 'package:terptune/services/database.dart';

class ReviewForm extends StatefulWidget {
  final String songId;

  const ReviewForm({Key? key, required this.songId});

  @override
  _ReviewFormState createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final TextEditingController _textController = TextEditingController();
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: TextFormField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'What do you think?',
              alignLabelWithHint: true,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Slider(
          value: _rating,
          onChanged: (value) {
            setState(() {
              _rating = value;
            });
          },
          min: 0,
          max: 5,
          divisions: 5,
          label: _rating.toString(),
        ),
        const SizedBox(height: 10),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              String uid = FirebaseAuth.instance.currentUser!.uid;
              try {
                await DatabaseService(uid: uid).addReview(
                  Review(
                    uid: uid,
                    songId: widget.songId,
                    text: _textController.text,
                    rating: _rating.toInt(),
                  ),
                );

                _textController.clear();
                setState(() {
                  _rating = 0;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Review submitted successfully!'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to submit review: $e')),
                );
              }
            },
            child: const Text('Submit Review'),
          ),
        ),
      ],
    );
  }
}

class ShakeOrBreakForm extends StatefulWidget {
  final String songId;

  const ShakeOrBreakForm({Key? key, required this.songId});

  @override
  _ShakeOrBreakFormState createState() => _ShakeOrBreakFormState();
}

class _ShakeOrBreakFormState extends State<ShakeOrBreakForm> {
  final TextEditingController _textController = TextEditingController();
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.red],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Center(
              child: Text(
                'SHAKE OR BREAK',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Center(
            child: TextFormField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'What do you think?',
                alignLabelWithHint: true,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Slider(
            value: _rating,
            onChanged: (value) {
              setState(() {
                _rating = value;
              });
            },
            min: 0,
            max: 5,
            divisions: 5,
            label: _rating.toString(),
          ),
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                String uid = FirebaseAuth.instance.currentUser!.uid;
                try {
                  await DatabaseService(uid: uid).addReview(
                    Review(
                      uid: uid,
                      songId: widget.songId,
                      text: _textController.text,
                      rating: _rating.toInt(),
                    ),
                  );

                  _textController.clear();
                  setState(() {
                    _rating = 0;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Review submitted successfully!'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to submit review: $e')),
                  );
                }
              },
              child: const Text('Submit Review'),
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewList extends StatelessWidget {
  final String songId;

  const ReviewList({Key? key, required this.songId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('songId', isEqualTo: songId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No reviews yet');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(data['uid']) // uid of the user who added the review
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (userSnapshot.hasError) {
                  return Text('Error: ${userSnapshot.error}');
                }
                if (!userSnapshot.hasData) {
                  return Text('Unknown user');
                }
                var userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;

                return Center(
                  child: ListTile(
                    title: Text(data['text']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rating: ${data['rating']}'),
                        Text('${userData!['name']}'),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
