import 'package:flutter/material.dart';
import '../services/api_client.dart';

class WalletProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  double balance = 0.0;
  String currency = 'NGN';
  List<dynamic> transactions = [];
  List<dynamic> banks = [];
  bool isLoading = false;

  Future<void> loadBalance() async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/api/wallet/balance');
      balance = (res['balance'] as num).toDouble();
      currency = res['currency'] ?? 'NGN';
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

  Future<void> loadBanks() async {
    try {
      banks = await _api.get('/api/wallet/banks') ?? [];
      notifyListeners();
    } catch (_) {}
  }

  /// Initialize Paystack payment → returns authorization_url & reference
  Future<Map<String, dynamic>?> fundWallet(double amount) async {
    try {
      final res = await _api.post('/api/wallet/fund', {'amount': amount});
      return res as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Fund error: $e');
      return null;
    }
  }

  /// After user pays on Paystack, call this with the reference
  Future<bool> verifyPayment(String reference) async {
    try {
      final res = await _api.post('/api/wallet/verify', {'reference': reference});
      if (res['success'] == true) {
        balance = (res['newBalance'] as num).toDouble();
        await loadTransactions();
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Cash out to Nigerian bank account via Paystack Transfer
  Future<bool> cashOut({
    required double amount,
    required String accountNumber,
    required String bankCode,
    required String accountName,
  }) async {
    try {
      final res = await _api.post('/api/wallet/cashout', {
        'amount': amount,
        'accountNumber': accountNumber,
        'bankCode': bankCode,
        'accountName': accountName,
      });
      if (res['success'] == true) {
        balance = (res['newBalance'] as num).toDouble();
        await loadTransactions();
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
