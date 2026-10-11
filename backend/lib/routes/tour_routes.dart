import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../db/database.dart';

class TourRoutes {
  Router get router {
    final r = Router();

    r.get('/<universityId>', (Request request, String universityId) async {
      final conn = await Database.connection;

      final result = await conn.execute(
        Sql.named('''
          SELECT id, title, description, pin_ids, estimated_minutes,
                 is_official, cover_image, university_id, created_by, created_at
          FROM tours WHERE university_id = @uni
          ORDER BY is_official DESC, created_at DESC
        '''),
        parameters: {'uni': universityId},
      );

      final tours = result.map((row) {
        final m = row.toColumnMap();
        return {
          'id': m['id'],
          'title': m['title'],
          'description': m['description'],
          'pinIds': m['pin_ids'] ?? [],
          'estimatedMinutes': m['estimated_minutes'],
          'isOfficial': m['is_official'],
          'coverImage': m['cover_image'],
          'universityId': m['university_id'],
          'createdBy': m['created_by'],
          'createdAt': m['created_at']?.toString(),
        };
      }).toList();

      return Response.ok(jsonEncode(tours),
          headers: {'Content-Type': 'application/json'});
    });

    r.post('/', (Request request) async {
      final userId = request.context['userId'] as String;
      final body = jsonDecode(await request.readAsString());
      final conn = await Database.connection;
      final id = const Uuid().v4();

      await conn.execute(
        Sql.named('''
          INSERT INTO tours (id, title, description, pin_ids, estimated_minutes,
                             is_official, cover_image, university_id, created_by)
          VALUES (@id, @title, @desc, @pins, @mins, @official, @cover, @uni, @userId)
        '''),
        parameters: {
          'id': id,
          'title': body['title'],
          'desc': body['description'],
          'pins': body['pinIds'] ?? [],
          'mins': body['estimatedMinutes'] ?? 30,
          'official': body['isOfficial'] ?? false,
          'cover': body['coverImage'],
          'uni': body['universityId'],
          'userId': userId,
        },
      );

      return Response.ok(jsonEncode({'id': id, ...body}),
          headers: {'Content-Type': 'application/json'});
    });

    return r;
  }
}
