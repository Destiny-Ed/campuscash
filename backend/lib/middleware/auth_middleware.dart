import 'package:shelf/shelf.dart';

Middleware authMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.forbidden('Missing or invalid Authorization header');
      }

      final token = authHeader.substring(7);
      // TODO: Verify JWT issued by backend after OAuth idToken exchange
      // For now we pass a simple userId for development
      final updated = request.change(context: {
        'userId': 'dev-user-id',
        'token': token,
      });

      return innerHandler(updated);
    };
  };
}
