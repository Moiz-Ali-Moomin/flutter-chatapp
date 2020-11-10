import 'package:chatapp/services/authenticate.dart';
import 'package:chatapp/services/functions.dart';
import 'package:chatapp/views/chatrooms.dart';
import 'package:chatapp/views/location.dart';
import 'package:chatapp/views/signin.dart';
import 'package:flutter/material.dart';
import 'views/addressPage.dart';
import 'views/signin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool userIsLoggedIn;

  @override
  void initState() {
    getLoggedInState();
    super.initState();
  }

  getLoggedInState() async {
    await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
      setState(() {
        userIsLoggedIn = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      debugShowCheckedModeBanner: false,
      initialRoute: "login",
      routes: {
        "login": (context) => SignIn(),
        "addressPage": (context) => Profile(),
        "map": (context) => Location()
      },
      theme: ThemeData(
        primaryColor: Colors.indigo[600],
        scaffoldBackgroundColor: Colors.grey[500],
        accentColor: Colors.blueAccent[500],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: userIsLoggedIn != null
          ? userIsLoggedIn
              ? ChatRoom()
              : Authenticate()
          : Container(
              child: Center(
                child: Authenticate(),
              ),
            ),
    );
  }
}
