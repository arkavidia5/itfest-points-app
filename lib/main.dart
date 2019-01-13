import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'give_page.dart';
import 'redeem_page.dart';
import 'initial_page_router.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final routes = <String, WidgetBuilder>{
    '/': (context) => InitialPageRouter(),
    LoginPage.tag: (context) => LoginPage(),
    HomePage.tag: (context) => HomePage(),
    GivePage.tag: (context) => GivePage(),
    RedeemPage.tag: (context) => RedeemPage(),
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
      routes: routes,
      initialRoute: '/',
    );
  }
}