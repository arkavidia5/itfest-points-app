import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'const.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

class Item {
  String name, tenant;
  int price, stock, max_stock;

  Item(this.name, this.tenant, this.price, this.stock, this.max_stock);
}

class RedeemPage extends StatefulWidget {
  static String tag = 'redeem-page';

  _RedeemPageState createState() => _RedeemPageState();
}

class _RedeemPageState extends State<RedeemPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  List<Item> items = List();

  Future<List<Item>> _getItems() async {
    // TODO implement getItems
    http.Response response = await http.get(Constants.BASE_URL + '/test/docs');

    List<Item> items = List();

    items.add(Item("Air Lada", "bx78byd3dhbcyduy43", 300, 500, 600));
    items.add(Item("Totebag Arkavidia", "bx78byd3dhbcyduy43", 300, 456, 500));

    return items;
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
                return Column(
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
}