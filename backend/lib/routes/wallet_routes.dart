import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class WalletRoutes {
  static final Map<String, double> _balances = {};
  static final Map<String, List<Map<String, dynamic>>> _transactions = {};

  Router get router {
    final r = Router();

    r.get('/balance', (Request request) {
      final userId = request.context['userId'] as String;
      final balance = _balances[userId] ?? 0.0;
      return Response.ok(jsonEncode({'balance': balance, 'currency': 'USD'}),
          headers: {'Content-Type': 'application/json'});
    });

    r.get('/transactions', (Request request) {
      final userId = request.context['userId'] as String;
      final txs = _transactions[userId] ?? [];
      return Response.ok(jsonEncode(txs),
          headers: {'Content-Type': 'application/json'});
    });

    r.post('/cashout', (Request request) async {
      final userId = request.context['userId'] as String;
      final body = jsonDecode(await request.readAsString());
      final amount = (body['amount'] as num).toDouble();

      final current = _balances[userId] ?? 0.0;
      if (amount > current) {
        return Response.badRequest(body: jsonEncode({'error': 'Insufficient balance'}));
      }

      _balances[userId] = current - amount;
      _transactions.putIfAbsent(userId, () => []);
      _transactions[userId]!.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'cashout',
        'amount': -amount,
        'method': body['method'] ?? 'paypal',
        'status': 'pending',
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      });

      return Response.ok(jsonEncode({'success': true, 'newBalance': _balances[userId]}),
          headers: {'Content-Type': 'application/json'});
    });

    return r;
  }
}
