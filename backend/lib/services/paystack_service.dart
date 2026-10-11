import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import 'package:uuid/uuid.dart';

class PaystackService {
  final String _secretKey;
  final String _baseUrl = 'https://api.paystack.co';

  PaystackService() : _secretKey = (DotEnv(includePlatformEnvironment: true)..load())['PAYSTACK_SECRET_KEY'] ?? '';

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_secretKey',
        'Content-Type': 'application/json',
      };

  /// Initialize a transaction (for funding wallet or paying for a gig)
  Future<Map<String, dynamic>> initializeTransaction({
    required String email,
    required double amount,
    required String userId,
    String? callbackUrl,
    Map<String, dynamic>? metadata,
  }) async {
    final reference = 'CC_${const Uuid().v4().replaceAll('-', '').substring(0, 16)}';
    final amountInKobo = (amount * 100).round();

    final body = {
      'email': email,
      'amount': amountInKobo,
      'reference': reference,
      'currency': 'NGN',
      'callback_url': callbackUrl,
      'metadata': {
        'user_id': userId,
        ...?metadata,
      },
    };

    final res = await http.post(
      Uri.parse('$_baseUrl/transaction/initialize'),
      headers: _headers,
      body: jsonEncode(body),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['status'] == true) {
      return {
        'authorization_url': data['data']['authorization_url'],
        'access_code': data['data']['access_code'],
        'reference': data['data']['reference'],
      };
    }
    throw Exception(data['message'] ?? 'Failed to initialize Paystack transaction');
  }

  /// Verify a transaction after payment
  Future<Map<String, dynamic>> verifyTransaction(String reference) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/transaction/verify/$reference'),
      headers: _headers,
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['status'] == true) {
      return data['data'];
    }
    throw Exception(data['message'] ?? 'Failed to verify transaction');
  }

  /// Create a transfer recipient (for cashout)
  Future<String> createTransferRecipient({
    required String name,
    required String accountNumber,
    required String bankCode,
  }) async {
    final body = {
      'type': 'nuban',
      'name': name,
      'account_number': accountNumber,
      'bank_code': bankCode,
      'currency': 'NGN',
    };

    final res = await http.post(
      Uri.parse('$_baseUrl/transferrecipient'),
      headers: _headers,
      body: jsonEncode(body),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 201 || (res.statusCode == 200 && data['status'] == true)) {
      return data['data']['recipient_code'];
    }
    throw Exception(data['message'] ?? 'Failed to create transfer recipient');
  }

  /// Initiate a transfer (cashout to bank)
  Future<Map<String, dynamic>> initiateTransfer({
    required String recipientCode,
    required double amount,
    required String reason,
    String? reference,
  }) async {
    final amountInKobo = (amount * 100).round();
    final ref = reference ?? 'CCOUT_${const Uuid().v4().replaceAll('-', '').substring(0, 12)}';

    final body = {
      'source': 'balance',
      'amount': amountInKobo,
      'recipient': recipientCode,
      'reason': reason,
      'reference': ref,
    };

    final res = await http.post(
      Uri.parse('$_baseUrl/transfer'),
      headers: _headers,
      body: jsonEncode(body),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['status'] == true) {
      return data['data'];
    }
    throw Exception(data['message'] ?? 'Failed to initiate transfer');
  }

  /// List banks (for cashout UI)
  Future<List<dynamic>> listBanks() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/bank?currency=NGN'),
      headers: _headers,
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['status'] == true) {
      return data['data'] as List;
    }
    throw Exception('Failed to fetch banks');
  }
}
