
import 'package:flutter/material.dart';
import 'package:terptune/screens/home/Profile.dart';
import 'package:terptune/screens/home/ExploreList.dart';
import 'package:terptune/services/auth.dart';
import 'package:terptune/services/SpotifyService.dart';
//import 'spotify_authentication.dart';
import 'ForYou.dart';
import 'package:google_fonts/google_fonts.dart';

// changing to stateful
class TerptuneHomepage extends StatelessWidget {
  TerptuneHomepage({Key? key, required this.title}) : super(key: key);

  final String title;
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        appBar: AppBar(
          title: Text(title, style: GoogleFonts.teko()),
          bottom: TabBar(
            labelStyle: GoogleFonts.montserrat(),
            labelColor: Colors.black,
            tabs: const [
              Tab(text: 'Explore'),
              Tab(text: 'For You'),
              Tab(text: 'Profile'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ExploreList(),
            ForYou(),
            ProfileView(),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: Theme.of(context).colorScheme.inverseSurface,
          child: Container(
            height: 50.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _auth.signOut();
                  },
                  child: Text('Log Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _navigateToNextScreen(BuildContext context) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => SpotifyService()));
}

/* class TopSongList extends StatelessWidget {
 @override
 Widget build(BuildContext context) {}
}*/
