import 'package:flutter/material.dart';

class SearchBoxController extends ChangeNotifier {
  String? objectName;

  SearchBoxController({String? objectName});

  String? get path => objectName;
  
  set url(String? newValue) {
    objectName = newValue;
    notifyListeners();
  }
}
