import 'package:flutter/material.dart';
import 'package:flutter_masterlink/widgets/appBar.dart';

class LoggerPage extends StatefulWidget {
  @override
  _LoggerPageState createState() => _LoggerPageState();
}

class _LoggerPageState extends State<LoggerPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [appBar(context, 'Logger data')],
      ),
    );
  }
}
