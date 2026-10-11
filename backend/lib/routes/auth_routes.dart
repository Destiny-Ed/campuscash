import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/auth_service.dart';

class AuthRoutes {
  final _auth = AuthService();

  Router get router {
    final r = Router();

    r.post('/login', (Request request) async {
      try {
        final body = jsonDecode(await request.readAsString());
        final idToken = body['idToken'] as String?;
        final fcmToken = body['fcmToken'] as String?;

        if (idToken == null || idToken.isEmpty) {
          return Response.badRequest(
            body: jsonEncode({'error': 'idToken is required'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final result = await _auth.loginWithGoogle(
          idToken: idToken,
          fcmToken: fcmToken,
        );

        return Response.ok(
          jsonEncode(result),
          headers: {'Content-Type': 'application/json'},
        );
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
