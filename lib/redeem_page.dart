import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'const.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker/numberpicker.dart';

typedef void ConfirmationCallback(int quantity);

class Item {
  String name, tenant, id;
  int price, stock, max_stock;

  Item(this.name, this.tenant, this.price, this.stock, this.max_stock, this.id);
}

class RedeemPage extends StatefulWidget {
  static String tag = 'redeem-page';

  _RedeemPageState createState() => _RedeemPageState();
}

class _RedeemPageState extends State<RedeemPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  int _redeemQty = 1;

  List<Item> items = List();

  Future<List<Item>> _getItems() async {
    // TODO implement getItems
    http.Response response = await http.get(Constants.BASE_URL + '/item/all');

    List data = json.decode(response.body);
    List<Item> items = List();

    data.forEach((item) {
      items.add(Item(item['name'], item['tenant'], item['price'], item['stock'], item['max_stock'], item['id']));
    });


    return items;
  }

  /**
   * Attempt to redeem
   */
  void _attemptRedeem(String barcode, String itemId, int qty) async {
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

    var headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': authHeader
    };

    String JSONbody = json.encode({
      'item_id': itemId,
      'user_id': barcode,
      'quantity': qty
    });

    http.Response response = await http.post(
        Constants.BASE_URL + '/transaction/item', headers: headers,
        body: JSONbody);

    var data = json.decode(response.body);

    // Pop, if possible
    try {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    } catch(e) {
      debugPrint(e.toString());
    }

    if(data is Map) {
      showDialog(
        context: context,
        barrierDismissible: true,
        child: Dialog(
            child: Padding(
                padding: EdgeInsets.all(24),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(child: Text("Transaction is successful!")),
                  ],
                )
            )
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: true,
        child: Dialog(
            child: Padding(
                padding: EdgeInsets.all(24),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Text(data)
                    )
                  ],
                )
            )
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // Retrieve items
    _getItems().then((List<Item> items) {
      setState(() {
        this.items  = items;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final header = Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.lightBlue,
      child: Padding(
          padding: EdgeInsets.fromLTRB(16, 64, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Material(
                color: Colors.transparent,
                clipBehavior: Clip.antiAlias,
                child: Text(
                  "Redeem Points",
                  style: TextStyle(fontSize: 28.0, color: Colors.white),
                ),
              ),
            ],
          )
      ),
    );

    final listView = RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () {
        return _getItems().then((List<Item> items) {
          setState(() {
            this.items  = items;
          });
        });
      },
      child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (BuildContext ctxt, int i) {
                Item item = items[i];
                return GestureDetector(
                  onTap: () {
                    scan(item);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(item.name, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
                              Text("${item.price} points", style: TextStyle(color: Colors.grey, fontSize: 16)),
                              LinearPercentIndicator(
                                width: MediaQuery.of(context).size.width - 32,
                                lineHeight: 16.0,
                                percent: item.stock/item.max_stock,
                                center: Text(
                                  "${item.stock} out of ${item.max_stock}",
                                  style: new TextStyle(fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                linearStrokeCap: LinearStrokeCap.roundAll,
                                backgroundColor: Colors.black12,
                                progressColor: Colors.teal,
                              ),
                            ],
                          )
                      ),
                      Divider(height: 5.0)
                    ],
                  )
                );
              }
          )
      )
    );

    final body = Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Column(
          children: <Widget>[
            header,
            Expanded(
              child: listView,
            )
          ]
      ),
    );

    return Scaffold(
      backgroundColor: ArkavColors.ARKAV_BROKEN_WHITE,
      key: _scaffoldKey,
      body: body
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
  Future scan(Item item) async {
    try {
      String barcode = await BarcodeScanner.scan();

      _confirmPointTopup(barcode, item);
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

  void _confirmPointTopup(String barcode, Item item) {
    showModalBottomSheet<void>(context: context,
        builder: (BuildContext context) {
          return _ConfirmBottomSheet(item, barcode, (int quantity) {
            _attemptRedeem(barcode, item.id, quantity);
          });
        });
  }
}

class _ConfirmBottomSheet extends StatefulWidget {
  final Item item;
  final String barcode;
  final ConfirmationCallback callback;

  _ConfirmBottomSheet(this.item, this.barcode, this.callback);

  _ConfirmBottomSheetState createState() => _ConfirmBottomSheetState(this.item, this.barcode, this.callback);
}

class _ConfirmBottomSheetState extends State<_ConfirmBottomSheet> {
  Item item;
  String barcode;
  ConfirmationCallback callback;
  int _redeemQty = 1;

  _ConfirmBottomSheetState(this.item, this.barcode, this.callback);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
                  child: Text(
                    "Pick a quantity",
                    style: TextStyle(fontSize: 28.0, color: Colors.black, fontWeight: FontWeight.bold),
                  )
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
                  child: Text(
                    "You are going to redeem ${item.name} for ${barcode}.",
                    style: TextStyle(fontSize: 18.0, color: Colors.black),
                  )
              ),
              Container(height: 10),
              Material(
                  borderRadius: BorderRadius.circular(4),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    color: Color.fromARGB(15, 0, 0, 0),
                    padding: EdgeInsets.all(8),
                    child:  Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text("Qty: ${_redeemQty}", style: TextStyle(fontSize: 18),),
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                            child: GestureDetector(
                              onTap: _showDialog,
                              child: Text("(change)", style: TextStyle(fontSize: 18, color: Colors.blue)),
                            ),
                          )
                        ]
                    ),
                  )
              ),
              Container(height: 20),
              Text("Total: ${item.price * _redeemQty} points", style: TextStyle(fontSize: 18),),
              Container(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: MaterialButton(
                          height: 48.0,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          color: Colors.black12,
                          child: Text('Cancel', style: TextStyle(color: Colors.black, fontSize: 22)),
                          elevation: 0,
                        ),
                      )
                  ),
                  Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: MaterialButton(
                          height: 48.0,
                          onPressed: () {
                            Navigator.of(context).pop();
                            callback(_redeemQty);
                          },
                          color: ArkavColors.ARKAV_ORANGE,
                          child: Text('Proceed', style: TextStyle(color: Colors.white, fontSize: 22)),
                          elevation: 0,
                        ),
                      )
                  ),
                ],
              )

            ],
          )
      )
    );
  }

  _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NumberPickerDialog.integer(
            initialIntegerValue: _redeemQty,
            minValue: 1,
            maxValue: item.stock,
            title: Text("Pick a quantity"),
        );
      }
    ).then((value) {
      if (value != null) {
        setState(() => _redeemQty = value);
      }
    });
  }
}
