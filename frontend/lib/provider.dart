import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:frontend/model/data_model.dart';
import 'package:frontend/service/api.dart';

class HomeScreenProvider extends ChangeNotifier{
  List<DataModel> _data = [];
  List<DataModel> get data => _data;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  final interval = 900000;
  Timer? _timer;

  HomeScreenProvider() {
    // Start periodic timer - first call happens after the interval
    _timer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      fetchData();
    });
  }
 
  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _data = await ApiService.fetchData();
    } catch (e) {
      print("Error: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

}
