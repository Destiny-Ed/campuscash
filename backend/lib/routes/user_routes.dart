import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import '../db/database.dart';

class UserRoutes {
  Router get router {
    final r = Router();

    r.get('/me', (Request request) async {
      final userId = request.context['userId'] as String;
      final conn = await Database.connection;

      final result = await conn.execute(
        Sql.named('SELECT * FROM users WHERE id = @id'),
        parameters: {'id': userId},
      );

      if (result.isEmpty) {
        return Response.notFound(jsonEncode({'error': 'User not found'}),
            headers: {'Content-Type': 'application/json'});
      }

      final m = result.first.toColumnMap();
      return Response.ok(
        jsonEncode({
          'id': m['id'],
          'email': m['email'],
          'displayName': m['display_name'],
          'photoUrl': m['photo_url'],
          'university': m['university_name'],
          'universityId': m['university_id'],
          'isVerifiedStudent': m['is_verified_student'] ?? false,
          'rating': m['rating'] ?? 0,
          'completedGigs': m['completed_gigs'] ?? 0,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    });

    r.put('/me', (Request request) async {
      final userId = request.context['userId'] as String;
      final body = jsonDecode(await request.readAsString());
      final conn = await Database.connection;

      await conn.execute(
        Sql.named('''
          UPDATE users SET
            display_name = COALESCE(@name, display_name),
            university_id = COALESCE(@uniId, university_id),
            university_name = COALESCE(@uniName, university_name),
            updated_at = NOW()
          WHERE id = @id
        '''),
        parameters: {
          'id': userId,
          'name': body['displayName'],
          'uniId': body['universityId'],
          'uniName': body['university'],
        },
      );

      return Response.ok(jsonEncode({'updated': true}),
          headers: {'Content-Type': 'application/json'});
    });

    return r;
  }
}
