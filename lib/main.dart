// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_masterlink/pages/buildPage.dart';
import 'package:flutter_masterlink/pages/customersPage.dart';
import 'package:flutter_masterlink/pages/devicesPage.dart';
import 'package:flutter_masterlink/pages/loggerPage.dart';
import 'package:flutter_masterlink/pages/measurmentPage.dart';
import 'package:flutter_masterlink/pages/settingsPage.dart';
import 'package:flutter_masterlink/pages/usersPage.dart';
import 'package:flutter_masterlink/widgets/drawer.dart';
import 'package:scoped_model/scoped_model.dart';
import 'models/navigationModel.dart';

void main() {
  runApp(FlutterMasterlinkApp());
}

class FlutterMasterlinkApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.dark()),
      home: MasterDetailPage(),
    );
  }
}

class MasterDetailPage extends StatefulWidget {
  @override
  _MasterDetailPageState createState() => _MasterDetailPageState();
}

class _MasterDetailPageState extends State<MasterDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        drawer: MyDrawer(),
        body: ScopedModel<NavigationModel>(
          model: navigationModel,
          child: ScopedModelDescendant<NavigationModel>(
            builder: (context, model, child) {
              switch (navigationModel.pageIndex) {
                case 0:
                  return DevicesPage();
                case 1:
                  return CustomersPage();
                case 2:
                  return UsersPage();
                case 3:
                  return BuildPage();
                case 4:
                  return MeasurmentsPage();
                case 5:
                  return LoggerPage();
                case 6:
                  return SettingsPage();
                default:
                  return DevicesPage();
              }
            },
          ),
        ));
  }
}
