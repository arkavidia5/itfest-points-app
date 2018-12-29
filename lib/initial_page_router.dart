import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'globals.dart' as globals;

class InitialPageRouter extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _InitialPageRouterState createState() => new _InitialPageRouterState();
}

class _InitialPageRouterState extends State<InitialPageRouter> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _routePage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getString("authHeader") == null) {
      // Has not logged in, route to login page
      globals.isLoggedIn = false;

      Navigator.of(context).pushNamed(LoginPage.tag);
    } else {
      // Logged in, route to Home
      // Set globals
      String authorization = prefs.getString("authHeader");
      bool isAdmin = prefs.getBool("isAdmin");

      globals.isLoggedIn = true;
      globals.authHeader = authorization;
      globals.isAdmin = isAdmin;

      Navigator.of(context).pushReplacementNamed(HomePage.tag);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _routePage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: CircularProgressIndicator()
      ),
    );
  }
}