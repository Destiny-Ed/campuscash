import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

class AuthRoutes {
  Router get router {
    final r = Router();

    // Exchange Firebase/Google idToken for our own JWT
    r.post('/login', (Request request) async {
      final body = jsonDecode(await request.readAsString());
      final idToken = body['idToken'] as String?;
      final fcmToken = body['fcmToken'] as String?;

      if (idToken == null) {
        return Response.badRequest(body: jsonEncode({'error': 'idToken required'}));
      }

      // In production: verify idToken with Google/Firebase, extract email & uid
      // Then create or fetch user, issue our own JWT

      final userId = const Uuid().v4();
      final jwt = 'campuscash.jwt.$userId'; // replace with real JWT

      return Response.ok(jsonEncode({
        'token': jwt,
        'user': {
          'id': userId,
          'email': 'student@university.edu',
          'displayName': 'Campus Student',
          'university': null,
          'isVerifiedStudent': false,
        }
      }), headers: {'Content-Type': 'application/json'});
    });

    r.post('/register', (Request request) async {
      final body = jsonDecode(await request.readAsString());
      // similar flow
      return Response.ok(jsonEncode({'message': 'Registered'}));
    });

    return r;
  }
}
