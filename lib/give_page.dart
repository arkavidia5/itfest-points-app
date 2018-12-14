import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

import 'const.dart';

class GivePage extends StatefulWidget {
  static String tag = 'give-page';
  _GivePageState createState() => _GivePageState();
}

class _GivePageState extends State<GivePage> with SingleTickerProviderStateMixin {
  Animation<double> animation, opacityAnimation;
  AnimationController controller;

  initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 900), vsync: this);

    final Animation curve = CurvedAnimation(parent: controller, curve: Interval(5/9, 1.0, curve: Curves.easeOut));
    animation = Tween(begin: 40.0, end: 0.0).animate(curve)
      ..addListener(() {
        setState(() {
          // the state that has changed here is the animation object’s value
        });
      });

    opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(curve)
      ..addListener(() {
        setState(() {
          // the state that has changed here is the animation object’s value
        });
      });

    controller.forward();
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
              Hero(
                tag: 'title-give',
                child: Material(
                  color: Colors.transparent,
                  clipBehavior: Clip.antiAlias,
                  child: Text(
                    "Give Points",
                    style: TextStyle(fontSize: 28.0, color: Colors.white),
                  ),
                ),
              )
            ],
          )
      ),
    );

    final pointIndic = Opacity(
      opacity: opacityAnimation.value,
      child: Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(top: animation.value),
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
                        Text(
                          "2500",
                          style: TextStyle(fontSize: 36.0, color: Colors.black),
                        ),
                      ],
                    )
                )
            ),
          )
      ),
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
              child: Opacity(
                opacity: opacityAnimation.value,
                child: topupNominal,
              )
          )
        ]
      ),
    );

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Hero(
            tag: 'give',
            child: Material(
              elevation: 0,
              color: Colors.deepOrangeAccent,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
          ),
          body
        ],
      ),
      backgroundColor: ArkavColors.ARKAV_BROKEN_WHITE,
    );
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }
}