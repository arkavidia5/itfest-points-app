import 'package:flutter/material.dart';
import 'const.dart';
import 'give_page.dart';

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
            child: Stack(
              children: <Widget>[
                Hero(
                  tag: heroTag,
                  child: Material(
                    elevation: 3,
                    shadowColor: Colors.black,
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      height: 150,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 150,
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 64, 16, 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Hero(
                            tag: 'title-' + heroTag,
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                menuName,
                                style: TextStyle(fontSize: 28.0, color: Colors.white),
                              ),
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
              ],
            )
          );
    }

    final listView = MediaQuery.removePadding(context: context,
      removeTop: true,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder<Null>(
                    pageBuilder: (BuildContext context, Animation<double> animation,
                        Animation<double> secondaryAnimation) {
                      return AnimatedBuilder(
                          animation: animation,
                          builder: (BuildContext context, Widget child) {
                            return Opacity(
                              opacity: animation.value,
                              child: GivePage(),
                            );
                          });
                    },
                    transitionDuration: Duration(milliseconds: 500)),
              );
            },
            child: getMenuMaterialWidget(Colors.deepOrangeAccent, 'give', 'Give Points', 'Give points to your visitors'),
          ),
          getMenuMaterialWidget(Colors.lightBlue, 'redeem', 'Redeem Points', 'Exchange points for items'),
        ],
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
