import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../db/database.dart';

class MapRoutes {
  Router get router {
    final r = Router();

    r.get('/pins/<universityId>', (Request request, String universityId) async {
      final conn = await Database.connection;
      final result = await conn.execute(
        Sql.named('''
          SELECT id, title, description, lat, lng, is_free, price, category,
                 photos, created_by, university_id, rating, visit_count, created_at
          FROM map_pins WHERE university_id = @uni
          ORDER BY created_at DESC
        '''),
        parameters: {'uni': universityId},
      );

      final pins = result.map((row) {
        final m = row.toColumnMap();
        return {
          'id': m['id'],
          'title': m['title'],
          'description': m['description'],
          'lat': m['lat'],
          'lng': m['lng'],
          'isFree': m['is_free'],
          'price': m['price'],
          'category': m['category'],
          'photos': m['photos'] ?? [],
          'createdBy': m['created_by'],
          'universityId': m['university_id'],
          'rating': m['rating'],
          'visitCount': m['visit_count'],
          'createdAt': m['created_at']?.toString(),
        };
      }).toList();

      return Response.ok(jsonEncode(pins),
          headers: {'Content-Type': 'application/json'});
    });

    r.post('/pins', (Request request) async {
      final userId = request.context['userId'] as String;
      final body = jsonDecode(await request.readAsString());
      final conn = await Database.connection;
      final id = const Uuid().v4();

      await conn.execute(
        Sql.named('''
          INSERT INTO map_pins (id, title, description, lat, lng, is_free, price, category, photos, created_by, university_id)
          VALUES (@id, @title, @desc, @lat, @lng, @isFree, @price, @cat, @photos, @userId, @uni)
        '''),
        parameters: {
          'id': id,
          'title': body['title'],
          'desc': body['description'] ?? '',
          'lat': body['lat'],
          'lng': body['lng'],
          'isFree': body['isFree'] ?? true,
          'price': body['price'],
          'cat': body['category'] ?? 'other',
          'photos': body['photos'] ?? [],
          'userId': userId,
          'uni': body['universityId'],
        },
      );

      return Response.ok(
        jsonEncode({
          'id': id,
          'title': body['title'],
          'description': body['description'],
          'lat': body['lat'],
          'lng': body['lng'],
          'isFree': body['isFree'] ?? true,
          'price': body['price'],
          'category': body['category'] ?? 'other',
          'photos': body['photos'] ?? [],
          'createdBy': userId,
          'universityId': body['universityId'],
        }),
        headers: {'Content-Type': 'application/json'},
      );
    });

    return r;
  }
}
