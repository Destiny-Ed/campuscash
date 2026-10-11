import 'package:flutter/material.dart';
import '../services/api_client.dart';

class TimetableProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  List<dynamic> entries = [];
  bool isLoading = false;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    try {
      entries = await _api.get('/api/timetable/') ?? [];
    } catch (_) {}
    isLoading = false;
    notifyListeners();
  }

  Future<bool> addEntry(Map<String, dynamic> data) async {
    try {
      final entry = await _api.post('/api/timetable/', data);
      entries.add(entry);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      await _api.delete('/api/timetable/$id');
      entries.removeWhere((e) => e['id'] == id);
      notifyListeners();
    } catch (_) {}
  }
}
