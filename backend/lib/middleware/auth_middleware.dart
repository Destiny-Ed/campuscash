import 'package:shelf/shelf.dart';
import '../services/auth_service.dart';

Middleware authMiddleware() {
  final authService = AuthService();

  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.forbidden(
          '{"error":"Missing or invalid Authorization header"}',
          headers: {'Content-Type': 'application/json'},
        );
      }

      final token = authHeader.substring(7);
      final payload = authService.verifyJwt(token);

      if (payload == null) {
        return Response.forbidden(
          '{"error":"Invalid or expired token"}',
          headers: {'Content-Type': 'application/json'},
        );
      }

      final updated = request.change(context: {
        'userId': payload['sub'],
        'email': payload['email'],
        'token': token,
      });

      return innerHandler(updated);
    };
  };
}
