import 'package:flutter/material.dart';
import '../services/api_client.dart';

class WalletProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  double balance = 0.0;
  List<dynamic> transactions = [];
  bool isLoading = false;

  Future<void> loadBalance() async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/api/wallet/balance');
      balance = (res['balance'] as num).toDouble();
    } catch (_) {}
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    try {
      transactions = await _api.get('/api/wallet/transactions') ?? [];
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> cashOut(double amount, String method) async {
    try {
      final res = await _api.post('/api/wallet/cashout', {
        'amount': amount,
        'method': method,
      });
      balance = (res['newBalance'] as num).toDouble();
      await loadTransactions();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
