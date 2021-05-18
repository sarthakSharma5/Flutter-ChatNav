import 'package:ChatNav/home.dart';
import 'package:ChatNav/login.dart';
import 'package:ChatNav/msg.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChatNav',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => GoSplash(),
        "/home": (context) => MyHomePage(),
        "/msg": (context) => Message(),
        "/login": (context) => LoginPage(),
      },
    );
  }
}

class GoSplash extends StatefulWidget {
  @override
  _GoSplashState createState() => _GoSplashState();
}

class _GoSplashState extends State<GoSplash> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
        seconds: 5,
        useLoader: true,
        navigateAfterSeconds: new LoginPage(),
        title: new Text(
          'ChatNav',
          style: new TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 40.0,
            color: Colors.indigo.shade900,
          ),
        ),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        loadingText: Text("Chat & Navigate using Maps"),
        image: Image(image: AssetImage("assets/chat.jpg")),
        photoSize: 100.0,
        loaderColor: Colors.red);
  }
}
