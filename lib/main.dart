import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Firebase Authentication'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<FirebaseApp> _firebaseApp;
  bool isLoggedIn = false;
  late String name;
  @override
  void initState() {
    super.initState();
    _firebaseApp = Firebase.initializeApp();
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void _googleSignIn() async {
    final googleSignIn = GoogleSignIn();
    final signInAccount = await googleSignIn.signIn();

    final googleAccountAuthentication = await signInAccount?.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: googleAccountAuthentication!.accessToken,
        idToken: googleAccountAuthentication.idToken);

    await FirebaseAuth.instance.signInWithCredential(credential);

    if (FirebaseAuth.instance.currentUser != null) {
      print('Google Authentication Sucessful');
      print('${FirebaseAuth.instance.currentUser?.displayName} signed in');
      setState(() {
        isLoggedIn = true;
        name = FirebaseAuth.instance.currentUser!.displayName!;
      });
    } else {
      print('Unable to Signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: _firebaseApp,
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          return (Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                isLoggedIn ? Text('$name Signed in') : Text(''),
                ElevatedButton(
                    onPressed: isLoggedIn ? _signOut : _googleSignIn,
                    child: isLoggedIn
                        ? Text('Sign out')
                        : Text('Sign in with google'))
              ],
            ),
          ));
        }),
      ),
    );
  }
}
