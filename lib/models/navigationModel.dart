// @dart=2.9
import 'package:scoped_model/scoped_model.dart';

class NavigationModel extends Model {
  int _pageIndex = 0;

  set pageIndex(int val) {
    _pageIndex = val;
    update();
  }

  int get pageIndex => _pageIndex;

  void update() {
    notifyListeners();
  }
}

NavigationModel navigationModel = NavigationModel();
