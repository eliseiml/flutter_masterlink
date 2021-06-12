import 'package:flutter/material.dart';
import 'package:flutter_masterlink/widgets/appBar.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [appBar(context, 'Users')],
      ),
    );
  }
}
