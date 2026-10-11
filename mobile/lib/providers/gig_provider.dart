import 'package:flutter/material.dart';
import '../services/api_client.dart';

class GigProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  List<dynamic> gigs = [];
  bool isLoading = false;
  String? activeFilter;

  Future<void> loadGigs({String? type, String? universityId}) async {
    isLoading = true;
    notifyListeners();
    try {
      String path = '/api/gigs/?';
      if (type != null) path += 'type=$type&';
      if (universityId != null) path += 'universityId=$universityId';
      gigs = await _api.get(path) ?? [];
      activeFilter = type;
    } catch (_) {}
    isLoading = false;
    notifyListeners();
  }

  Future<bool> createGig(Map<String, dynamic> data) async {
    try {
      final gig = await _api.post('/api/gigs/', data);
      gigs.insert(0, gig);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createProjectWriting(Map<String, dynamic> data) async {
    try {
      final gig = await _api.post('/api/gigs/project-writing', data);
      gigs.insert(0, gig);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
