import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  bool isLoading = false;
  bool isAuthenticated = false;
  Map<String, dynamic>? user;

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    if (token != null) {
      isAuthenticated = true;
      try {
        user = await _api.get('/api/users/me');
      } catch (_) {}
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    isLoading = true;
    notifyListeners();
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return false;

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('No idToken');

      // Get FCM token (only Firebase usage besides OAuth)
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (_) {}

      final res = await _api.post('/api/auth/login', {
        'idToken': idToken,
        'fcmToken': fcmToken,
      }, auth: false);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt', res['token']);
      user = res['user'];
      isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Auth error: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    isAuthenticated = false;
    user = null;
    notifyListeners();
  }
}
