import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../db/database.dart';

class TimetableRoutes {
  Router get router {
    final r = Router();

    r.get('/', (Request request) async {
      final userId = request.context['userId'] as String;
      final conn = await Database.connection;

      final result = await conn.execute(
        Sql.named('''
          SELECT id, course_code, title, day_of_week, start_time, end_time,
                 location_pin_id, is_recurring, created_at
          FROM timetable_entries WHERE user_id = @userId
          ORDER BY day_of_week, start_time
        '''),
        parameters: {'userId': userId},
      );

      final entries = result.map((row) {
        final m = row.toColumnMap();
        return {
          'id': m['id'],
          'courseCode': m['course_code'],
          'title': m['title'],
          'dayOfWeek': m['day_of_week'],
          'startTime': m['start_time'],
          'endTime': m['end_time'],
          'locationPinId': m['location_pin_id'],
          'isRecurring': m['is_recurring'],
          'createdAt': m['created_at']?.toString(),
        };
      }).toList();

      return Response.ok(jsonEncode(entries),
          headers: {'Content-Type': 'application/json'});
    });

    r.post('/', (Request request) async {
      final userId = request.context['userId'] as String;
      final body = jsonDecode(await request.readAsString());
      final conn = await Database.connection;
      final id = const Uuid().v4();

      await conn.execute(
        Sql.named('''
          INSERT INTO timetable_entries (id, user_id, course_code, title, day_of_week,
                                         start_time, end_time, location_pin_id, is_recurring)
          VALUES (@id, @userId, @course, @title, @day, @start, @end, @pin, @recurring)
        '''),
        parameters: {
          'id': id,
          'userId': userId,
          'course': body['courseCode'],
          'title': body['title'],
          'day': body['dayOfWeek'],
          'start': body['startTime'],
          'end': body['endTime'],
          'pin': body['locationPinId'],
          'recurring': body['isRecurring'] ?? true,
        },
      );

      return Response.ok(jsonEncode({'id': id, ...body}),
          headers: {'Content-Type': 'application/json'});
    });

    r.delete('/<id>', (Request request, String id) async {
      final userId = request.context['userId'] as String;
      final conn = await Database.connection;

      await conn.execute(
        Sql.named('DELETE FROM timetable_entries WHERE id = @id AND user_id = @userId'),
        parameters: {'id': id, 'userId': userId},
      );

      return Response.ok(jsonEncode({'deleted': true}),
          headers: {'Content-Type': 'application/json'});
    });

    return r;
  }
}
