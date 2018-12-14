import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'give_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) => LoginPage(),
    HomePage.tag: (context) => HomePage(),
    GivePage.tag: (context) => GivePage(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arkavidia Points',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        fontFamily: 'Nunito',
      ),
      home: LoginPage(),
      routes: routes,
    );
  }
}