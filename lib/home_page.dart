import 'package:flutter/material.dart';
import 'const.dart';
import 'give_page.dart';
import 'globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  static String tag = 'home-page';

  @override
  Widget build(BuildContext context) {
    final welcome = Container(
        width: MediaQuery.of(context).size.width,
        child: AspectRatio(
          aspectRatio: 16.0/9.0,
          child: Container(
              width: MediaQuery.of(context).size.width,
              color: ArkavColors.ARKAV_ORANGE,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 48, 24, 24),
                  child: Stack(
                    children: <Widget>[
                      Image(
                        image: AssetImage('assets/arkavpoints.png'),
                        height: 22,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Warung Pintar',
                            style: TextStyle(fontSize: 28.0, color: Colors.white),
                          ),
                          Text(
                            'warpin2502',
                            style: TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ],
                      )
                    ],
                  )
              )
            ),
          )
    );

    getMenuMaterialWidget(Color color, String heroTag, String menuName, String menuDescription) {
      return Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Material(
                elevation: 3,
                shadowColor: Colors.black,
                color: color,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 150,
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 64, 16, 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Material(
                            color: Colors.transparent,
                            child: Text(
                              menuName,
                              style: TextStyle(fontSize: 28.0, color: Colors.white),
                            ),
                          ),
                          Text(
                            menuDescription,
                            style: TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ],
                      )
                  ),
                )
            ),
          );
    }

    getAllowedMenu() {
      bool isAdmin = globals.isAdmin;

      if(isAdmin) {
        return <Widget>[
          getMenuMaterialWidget(Colors.lightBlue, 'redeem', 'Redeem Points', 'Exchange points for items'),
        ];
      } else {
        return <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(GivePage.tag);
            },
            child: getMenuMaterialWidget(Colors.deepOrangeAccent, 'give', 'Give Points', 'Give points to your visitors'),
          )
        ];
      }
    }

    final listView = MediaQuery.removePadding(context: context,
      removeTop: true,
      child: ListView(
        shrinkWrap: true,
        children: getAllowedMenu()
      ),
    );

    final body = Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          welcome,
          Expanded(
            child: listView,
          )
        ],
      ),
    );

    return Scaffold(
      body: body,
      backgroundColor: ArkavColors.ARKAV_BROKEN_WHITE,
    );
  }
}
