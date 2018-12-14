import 'package:flutter/material.dart';
import 'package:arkavidia_points/home_page.dart';
import 'const.dart';
import 'package:http/http.dart' as http;


class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String email, password;

  bool isLoading = false;

  void attemptLogin(String username, String password) async {
    setState(() {
      isLoading = true;
    });
    http.Response response = await http.get('https://jsonplaceholder.typicode.com/posts/1');

    Navigator.of(context).pushReplacementNamed(HomePage.tag);
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
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      initialValue: '',
      onSaved: (String value) { this.email = value; },
      decoration: InputDecoration(
        hintText: 'Username',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextFormField(
      autofocus: false,
      initialValue: '',
      obscureText: true,
      onSaved: (String value) { this.password = value; },
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = Padding(
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
            attemptLogin(this.email, this.password);
          },
          color: ArkavColors.ARKAV_ORANGE,
          child: Text('Log In', style: TextStyle(color: Colors.white)),
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
            loginButton
          ],
        );
      }
    }

    // Main view
    return Scaffold(
      backgroundColor: ArkavColors.ARKAV_BROKEN_WHITE,
      body: Center(
        child: getBody()
      ),
    );
  }
}