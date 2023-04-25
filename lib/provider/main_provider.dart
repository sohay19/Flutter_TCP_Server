
import 'package:flutter/widgets.dart';

import '../view_model/main_view_model.dart';


class MainProvider with ChangeNotifier {
  late MainViewModel _mainViewmodel;

  String get message => _mainViewmodel.message;


  MainProvider() {
    _mainViewmodel = new MainViewModel();
    _mainViewmodel.notify = notifyListeners;
  }

  clearMessage() {
    _mainViewmodel.clearMessage();
  }

  openServer() {
    _mainViewmodel.openServer();
  }

  closeServer() {
    _mainViewmodel.closeServer();
  }
}