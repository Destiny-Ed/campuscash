import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../db/database.dart';
import '../services/paystack_service.dart';

class WalletRoutes {
  final _paystack = PaystackService();

  Router get router {
    final r = Router();

    // Get balance
    r.get('/balance', (Request request) async {
      final userId = request.context['userId'] as String;
      final conn = await Database.connection;

      final result = await conn.execute(
        Sql.named('SELECT balance, currency FROM wallets WHERE user_id = @id'),
        parameters: {'id': userId},
      );

      if (result.isEmpty) {
        return Response.ok(jsonEncode({'balance': 0.0, 'currency': 'NGN'}),
            headers: {'Content-Type': 'application/json'});
      }

      final row = result.first.toColumnMap();
      return Response.ok(
        jsonEncode({
          'balance': row['balance'],
          'currency': row['currency'] ?? 'NGN',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    });

    // Transaction history
    r.get('/transactions', (Request request) async {
      final userId = request.context['userId'] as String;
      final conn = await Database.connection;

      final result = await conn.execute(
        Sql.named('''
          SELECT id, type, amount, currency, status, reference, description, created_at
          FROM transactions WHERE user_id = @id
          ORDER BY created_at DESC LIMIT 50
        '''),
        parameters: {'id': userId},
      );

      final txs = result.map((row) {
        final m = row.toColumnMap();
        return {
          'id': m['id'],
          'type': m['type'],
          'amount': m['amount'],
          'currency': m['currency'],
          'status': m['status'],
          'reference': m['reference'],
          'description': m['description'],
          'createdAt': m['created_at']?.toString(),
        };
      }).toList();

      return Response.ok(jsonEncode(txs),
          headers: {'Content-Type': 'application/json'});
    });

    // Initialize Paystack payment (fund wallet)
    r.post('/fund', (Request request) async {
      try {
        final userId = request.context['userId'] as String;
        final email = request.context['email'] as String;
        final body = jsonDecode(await request.readAsString());
        final amount = (body['amount'] as num).toDouble();

        if (amount < 100) {
          return Response.badRequest(
            body: jsonEncode({'error': 'Minimum amount is ₦100'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final init = await _paystack.initializeTransaction(
          email: email,
          amount: amount,
          userId: userId,
          metadata: {'purpose': 'wallet_funding'},
        );

        // Record pending transaction
        final conn = await Database.connection;
        final txId = const Uuid().v4();
        await conn.execute(
          Sql.named('''
            INSERT INTO transactions (id, user_id, type, amount, status, reference, paystack_reference, description)
            VALUES (@id, @userId, 'credit', @amount, 'pending', @ref, @ref, 'Wallet funding')
          '''),
          parameters: {
            'id': txId,
            'userId': userId,
            'amount': amount,
            'ref': init['reference'],
          },
        );

        return Response.ok(jsonEncode(init),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // Verify payment & credit wallet
    r.post('/verify', (Request request) async {
      try {
        final userId = request.context['userId'] as String;
        final body = jsonDecode(await request.readAsString());
        final reference = body['reference'] as String;

        final verified = await _paystack.verifyTransaction(reference);

        if (verified['status'] != 'success') {
          return Response.badRequest(
            body: jsonEncode({'error': 'Payment not successful'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final amount = (verified['amount'] as num) / 100; // kobo → Naira
        final conn = await Database.connection;

        // Update transaction + credit wallet in a simple flow
        await conn.execute(
          Sql.named('''
            UPDATE transactions SET status = 'success'
            WHERE reference = @ref AND user_id = @userId
          '''),
          parameters: {'ref': reference, 'userId': userId},
        );

        await conn.execute(
          Sql.named('''
            UPDATE wallets SET balance = balance + @amount, updated_at = NOW()
            WHERE user_id = @userId
          '''),
          parameters: {'amount': amount, 'userId': userId},
        );

        final bal = await conn.execute(
          Sql.named('SELECT balance FROM wallets WHERE user_id = @id'),
          parameters: {'id': userId},
        );

        return Response.ok(
          jsonEncode({
            'success': true,
            'amount': amount,
            'newBalance': bal.first.toColumnMap()['balance'],
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // Cash out to bank via Paystack Transfer
    r.post('/cashout', (Request request) async {
      try {
        final userId = request.context['userId'] as String;
        final body = jsonDecode(await request.readAsString());

        final amount = (body['amount'] as num).toDouble();
        final accountNumber = body['accountNumber'] as String;
        final bankCode = body['bankCode'] as String;
        final accountName = body['accountName'] as String? ?? 'CampusCash User';

        final conn = await Database.connection;

        final balRes = await conn.execute(
          Sql.named('SELECT balance FROM wallets WHERE user_id = @id'),
          parameters: {'id': userId},
        );

        final current = (balRes.first.toColumnMap()['balance'] as num).toDouble();
        if (amount > current) {
          return Response.badRequest(
            body: jsonEncode({'error': 'Insufficient balance'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        if (amount < 100) {
          return Response.badRequest(
            body: jsonEncode({'error': 'Minimum cashout is ₦100'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // Create recipient + transfer
        final recipientCode = await _paystack.createTransferRecipient(
          name: accountName,
          accountNumber: accountNumber,
          bankCode: bankCode,
        );

        final transfer = await _paystack.initiateTransfer(
          recipientCode: recipientCode,
          amount: amount,
          reason: 'CampusCash cashout',
        );

        // Debit wallet + record transaction
        await conn.execute(
          Sql.named('UPDATE wallets SET balance = balance - @amount, updated_at = NOW() WHERE user_id = @id'),
          parameters: {'amount': amount, 'id': userId},
        );

        final txId = const Uuid().v4();
        await conn.execute(
          Sql.named('''
            INSERT INTO transactions (id, user_id, type, amount, status, reference, paystack_reference, description)
            VALUES (@id, @userId, 'cashout', @amount, 'success', @ref, @paystackRef, 'Cashout to bank')
          '''),
          parameters: {
            'id': txId,
            'userId': userId,
            'amount': -amount,
            'ref': transfer['reference'] ?? txId,
            'paystackRef': transfer['transfer_code'],
          },
        );

        return Response.ok(
          jsonEncode({
            'success': true,
            'transfer': transfer,
            'newBalance': current - amount,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // List Nigerian banks
    r.get('/banks', (Request request) async {
      try {
        final banks = await _paystack.listBanks();
        return Response.ok(jsonEncode(banks),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    return r;
  }
}
