import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:terptune/models/users.dart";
import "package:terptune/screens/auth/authenticate.dart";
import "package:terptune/screens/home/home.dart";

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Users?>(context);

    if (user == null) {
      return Authenticate();
    } else {
      return TerptuneHomepage(
        title: 'TERPTUNE',
      );
    }
  }
}
