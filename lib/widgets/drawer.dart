// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_masterlink/models/navigationModel.dart';
import 'package:flutter_masterlink/utilites/colors.dart';

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          children: [
            drawerButton(context, 'Devices', 0),
            drawerButton(context, 'Customers', 1),
            drawerButton(context, 'Users', 2),
            drawerButton(context, 'Build', 3),
            drawerButton(context, 'Measurments', 4),
            drawerButton(context, 'Logger data', 5),
            drawerButton(context, 'Settings', 6)
          ],
        ),
      ),
    );
  }

  Widget drawerButton(BuildContext context, String title, int value) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        setState(() {
          navigationModel.pageIndex = value;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.only(left: 15),
        decoration: BoxDecoration(
            color: navigationModel.pageIndex == value
                ? kDarkColor
                : kBackgroundColor,
            border:
                Border(bottom: BorderSide(color: kAccentColor, width: 0.2))),
        child: Row(
          children: [
            Expanded(
              child: Text(title),
            ),
            Radio<int>(
                activeColor: kAccentColor,
                visualDensity: VisualDensity.comfortable,
                value: value,
                groupValue: navigationModel.pageIndex,
                onChanged: (val) {})
          ],
        ),
      ),
    );
  }
}
