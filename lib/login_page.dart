import 'package:flutter/material.dart';
import 'package:arkavidia_points/home_page.dart';
import 'const.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  void attemptLogin(String username, String password, bool isAdmin) async {
    setState(() {
      isLoading = true;
    });

    http.Response response = null;

    var headers = {
      'Content-type' : 'application/json',
      'Accept': 'application/json',
    };

    if(isAdmin) {
      String JSONbody = json.encode({
        'username': username,
        'password': password
      });

      response = await http.post(Constants.BASE_URL + '/admin/login', body: JSONbody, headers: headers);
    } else {
      String JSONbody = json.encode({
        'name': username,
        'password': password
      });

      response = await http.post(Constants.BASE_URL + '/tenant/login', body: JSONbody, headers: headers);
    }

    // Check response
    if(response.body.contains("OK")) {
      // All is well

      // Retrieve authorization header
      String authorization = response.headers['authorization'];
      globals.isLoggedIn = true;
      globals.authHeader = authorization;
      globals.isAdmin = isAdmin;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("isLoggedIn", true);
      await prefs.setString("authHeader", authorization);
      await prefs.setBool("isAdmin", isAdmin);
      await prefs.setString("username", username);

      // If tenant, retrieve info
      if(!isAdmin) {
        http.Response info = await http.get(Constants.BASE_URL + '/tenant/' + username);
        var tenant = json.decode(info.body);
        await prefs.setString("name", tenant['detail_name']);
      } else {
        await prefs.setString("name", 'Administrator');
      }

      Navigator.of(context).pushReplacementNamed(HomePage.tag);
    } else {
      setState(() {
        isLoading = false;
      });

      final snackBar = SnackBar(
        content: Text('Invalid username and/or password.'),
        action: SnackBarAction(label: "OK", onPressed: null),
    );

      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logo = CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/logo-arkav.png')
    );

    final email = TextFormField(
      controller: usernameController,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Username',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextFormField(
      controller: passwordController,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final tenantLoginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        shadowColor: ArkavColors.ARKAV_ORANGE,
        clipBehavior: Clip.antiAlias,
        elevation: 5.0,
        child: MaterialButton(
          minWidth: 200.0,
          height: 48.0,
          onPressed: () {
            attemptLogin(usernameController.text, passwordController.text, false);
          },
          color: ArkavColors.ARKAV_ORANGE,
          child: Text('Sign in as Tenant', style: TextStyle(color: Colors.white)),
        ),
      ),
    );

    final adminLoginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        shadowColor: Colors.lightBlue,
        clipBehavior: Clip.antiAlias,
        elevation: 5.0,
        child: MaterialButton(
          minWidth: 200.0,
          height: 48.0,
          onPressed: () {
            attemptLogin(usernameController.text, passwordController.text, true);
          },
          color: Colors.lightBlue,
          child: Text('Sign in as Admin', style: TextStyle(color: Colors.white)),
        ),
      ),
    );

    getBody() {
      if (isLoading) {
        return Center(child: CircularProgressIndicator());
      } else {
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 48.0),
            email,
            SizedBox(height: 8.0),
            password,
            SizedBox(height: 24.0),
            tenantLoginButton,
            adminLoginButton
          ],
        );
      }
    }

    // Main view
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ArkavColors.ARKAV_BROKEN_WHITE,
      body: Center(
        child: getBody()
      ),
    );
  }
}