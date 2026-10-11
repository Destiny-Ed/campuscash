import 'package:flutter/material.dart';
import '../services/api_client.dart';

class TourProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  List<dynamic> tours = [];
  bool isLoading = false;

  Future<void> loadTours(String universityId) async {
    isLoading = true;
    notifyListeners();
    try {
      tours = await _api.get('/api/tours/$universityId') ?? [];
    } catch (_) {}
    isLoading = false;
    notifyListeners();
  }
}
