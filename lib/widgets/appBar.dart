import 'package:flutter/material.dart';

Widget appBar(BuildContext context, String title) {
  return Container(
    margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
    child: Row(
      children: [
        IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: Icon(Icons.menu)),
        Text(title)
      ],
    ),
  );
}
