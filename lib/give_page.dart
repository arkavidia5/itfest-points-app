import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'const.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

class GivePage extends StatefulWidget {
  static String tag = 'give-page';
  _GivePageState createState() => _GivePageState();
}

class _GivePageState extends State<GivePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // States
  bool isLoadingPoints = true;
  int currentPoint = 0;

  /**
   * Retrieve tenant points
   */
  void _retrieveTenantPoints() async {
    setState(() {
      isLoadingPoints = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tenantName = prefs.getString("username");

    http.Response response = await http.get(Constants.BASE_URL + '/tenant/' + tenantName);
    var tenant = json.decode(response.body);

    setState(() {
      isLoadingPoints = false;
      currentPoint = tenant['point'];
    });
  }

  /**
   * Attempt point deduction
   */
  void _attemptDeduction(String barcode, int point) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      child: Dialog(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 8),
                child: CircularProgressIndicator(),
              ),
              Text("Loading"),
            ],
          )
        )
      ),
    );

    // Attempt to deduce
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authHeader = prefs.getString("authHeader");
    String username = prefs.getString("username");

    var headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': authHeader
    };

    String JSONbody = json.encode({
      'tenant_name': username,
      'user_id': barcode,
      'point': point
    });

    http.Response response = await http.post(
        Constants.BASE_URL + '/transaction/point', headers: headers,
        body: JSONbody);

    Navigator.of(context).pop();
    _retrieveTenantPoints();

    final snackBar = SnackBar(
        content: Text(response.body)
    );

    // TODO troubleshoot, it won't show
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  initState() {
    super.initState();
    _retrieveTenantPoints();
  }

  @override
  Widget build(BuildContext context) {

    final header = Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.transparent,
      child: Padding(
          padding: EdgeInsets.fromLTRB(16, 64, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Material(
                color: Colors.transparent,
                clipBehavior: Clip.antiAlias,
                child: Text(
                  "Give Points",
                  style: TextStyle(fontSize: 28.0, color: Colors.white),
                ),
              ),
            ],
          )
      ),
    );

    Widget getPointLabel() {
      if(isLoadingPoints) {
        return Padding(
            padding: EdgeInsets.all(0),
            child: Center(child: CircularProgressIndicator())
        );
      } else {
        return Center(
          child: Text(
            currentPoint.toString(),
            style: TextStyle(fontSize: 36.0, color: Colors.black),
          )
        );
      }
    }

    final pointIndic = Container(
        width: MediaQuery.of(context).size.width,
        //margin: EdgeInsets.only(top: animation.value),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
              shadowColor: Colors.black,
              child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: <Widget>[
                      Text(
                          "Your remaining points:"
                      ),
                      Container(
                        height: 70,
                        child: getPointLabel(),
                      ),
                    ],
                  )
              )
          ),
        )
    );

    final topupNominal = Padding(
        padding: EdgeInsets.all(8),
        child: GridView.count(
          childAspectRatio: 3/2,
          // Create a grid with 2 columns. If you change the scrollDirection to
          // horizontal, this would produce 2 rows.
          crossAxisCount: 3,
          // Generate 100 Widgets that display their index in the List
          children: List.generate(((250 - 50) ~/ 25) + 1, (index) {
            return Padding(
                padding: EdgeInsets.all(8),
                child: GestureDetector(
                  child: Material(
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          '${50 + ((index - 1) * 25)}',
                          style: Theme.of(context).textTheme.headline,
                        ),
                      )
                  ),
                  onTap: () {
                    scan(50 + ((index - 1) * 25));
                  }
                )
            );
          }),
        )
    );

    final body = Container(
      color: Colors.transparent,
      width: MediaQuery.of(context).size.width,
      child: Column(
          children: <Widget>[
            header,
            pointIndic,
            Expanded(
                child: topupNominal
            )
          ]
      ),
    );

    return Scaffold(
      backgroundColor: ArkavColors.ARKAV_BROKEN_WHITE,
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Material(
            elevation: 0,
            color: Colors.deepOrangeAccent,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
          body
        ],
      ),
    );
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /**
   * Scan barcode
   */
  Future scan(int nominal) async {
    try {
      String barcode = await BarcodeScanner.scan();

      _confirmPointTopup(barcode, nominal);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        /*setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
       */
        _showDialog("Error", "Camera permission is not granted");
      } else {
        //setState(() => this.barcode = 'Unknown error: $e');
        _showDialog("Error", "Unknown error: $e");
      }
    } on FormatException {
      //setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
      //_showDialog("Unknown error: $e");
    } catch (e) {
      //setState(() => this.barcode = 'Unknown error: $e');
      _showDialog("Error", "Unknown error: $e");
    }
  }

  void _confirmPointTopup(String barcode, int point) {
    showModalBottomSheet<void>(context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
                    child: Text(
                      "Are you sure?",
                      style: TextStyle(fontSize: 28.0, color: Colors.black, fontWeight: FontWeight.bold),
                    )
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
                    child: Text(
                      "You are going to transfer $point points to $barcode",
                      style: TextStyle(fontSize: 18.0, color: Colors.black),
                    )
                ),
                Container(height: 40),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: MaterialButton(
                            height: 56.0,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            color: Colors.black12,
                            child: Text('No, cancel', style: TextStyle(color: Colors.black, fontSize: 22)),
                            elevation: 0,
                          ),
                        )
                    ),
                    Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: MaterialButton(
                            height: 56.0,
                            onPressed: () {
                              Navigator.of(context).pop();
                              _attemptDeduction(barcode, point);
                            },
                            color: ArkavColors.ARKAV_ORANGE,
                            child: Text('Yes, sure!', style: TextStyle(color: Colors.white, fontSize: 22)),
                            elevation: 0,
                          ),
                        )
                    ),
                  ],
                )

              ],
            )
          );
        });
  }
}