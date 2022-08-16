import "package:flutter/material.dart";
import "widgets/LoadingScreen.dart";
import "pages/Home.dart";
import 'pages/Items.dart';
import 'pages/Launcher.dart';
import 'pages/Item.dart';
import 'package:http/http.dart' as http;

main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
