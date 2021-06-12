import 'package:flutter/material.dart';
import 'package:flutter_masterlink/widgets/appBar.dart';

class MeasurmentsPage extends StatefulWidget {
  @override
  _MeasurmentsPageState createState() => _MeasurmentsPageState();
}

class _MeasurmentsPageState extends State<MeasurmentsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [appBar(context, 'Measurments')],
      ),
    );
  }
}
