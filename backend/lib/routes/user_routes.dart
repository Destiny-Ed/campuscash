import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class UserRoutes {
  Router get router {
    final r = Router();

    r.get('/me', (Request request) {
      final userId = request.context['userId'] as String;
      return Response.ok(jsonEncode({
        'id': userId,
        'email': 'student@university.edu',
        'displayName': 'Campus Student',
        'university': 'Demo University',
        'isVerifiedStudent': true,
        'rating': 4.8,
        'completedGigs': 12,
      }), headers: {'Content-Type': 'application/json'});
    });

    r.put('/me', (Request request) async {
      final body = jsonDecode(await request.readAsString());
      // update profile logic
      return Response.ok(jsonEncode({'updated': true, ...body}),
          headers: {'Content-Type': 'application/json'});
    });

    return r;
  }
}
