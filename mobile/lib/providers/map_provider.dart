import 'package:flutter/material.dart';
import '../services/api_client.dart';

class MapProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  List<dynamic> pins = [];
  dynamic selectedPin;
  bool isLoading = false;

  Future<void> loadPins(String universityId) async {
    isLoading = true;
    notifyListeners();
    try {
      pins = await _api.get('/api/map/pins/$universityId') ?? [];
    } catch (_) {}
    isLoading = false;
    notifyListeners();
  }

  Future<bool> addPin(Map<String, dynamic> data) async {
    try {
      final pin = await _api.post('/api/map/pins', data);
      pins.add(pin);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void selectPin(dynamic pin) {
    selectedPin = pin;
    notifyListeners();
  }

  void clearSelection() {
    selectedPin = null;
    notifyListeners();
  }
}
