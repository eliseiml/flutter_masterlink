import 'package:flutter/material.dart';
import 'package:flutter_masterlink/widgets/appBar.dart';

class CustomersPage extends StatefulWidget {
  @override
  _CustomersPageState createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [appBar(context, 'Customers')],
      ),
    );
  }
}
