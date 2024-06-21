import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:terptune/services/auth.dart';
import 'package:terptune/shared/loading.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn({required this.toggleView});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            appBar: AppBar(
                backgroundColor: Color.fromARGB(255, 149, 110, 156),
                elevation: 0.0,
                title: Text(
                  "Sign in to Terptune!",
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: GoogleFonts.ubuntu().fontFamily,
                  ),
                ),
                actions: <Widget>[
                  TextButton.icon(
                      icon: Icon(Icons.person, color: Colors.white),
                      label: Text('Register',
                          style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        widget.toggleView();
                      })
                ]),
            body: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 50.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Email...',
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 122, 78, 130),
                              width: 2.0,
                            ),
                          ),
                        ),
                        validator: (val) =>
                            val!.isEmpty ? "Enter an email" : null,
                        onChanged: (val) {
                          setState(() => email = val);
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Password...',
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 122, 78, 130),
                              width: 2.0,
                            ),
                          ),
                        ),
                        obscureText: true,
                        validator: (val) => val!.length < 6
                            ? "Enter a password 6+ chars long"
                            : null,
                        onChanged: (val) {
                          setState(() => password = val);
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        child: const Text(
                          "Sign in",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => loading = true);
                            dynamic result =
                                await _auth.signInWithEmailAndPassword(
                              email,
                              password,
                            );

                            if (result == null) {
                              setState(() {
                                error =
                                    'Did not find acc with these credentials';
                                loading = false;
                              });
                            }
                          }
                        },
                      ),
                      SizedBox(height: 12),
                      Text(
                        error,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                      Image.network(
                        'https://i.pinimg.com/originals/a7/4a/11/a74a112552516ba3d21e17a57622451f.gif',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
