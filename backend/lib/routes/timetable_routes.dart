import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

class TimetableRoutes {
  static final Map<String, List<Map<String, dynamic>>> _timetables = {};

  Router get router {
    final r = Router();

    r.get('/', (Request request) {
      final userId = request.context['userId'] as String;
      final entries = _timetables[userId] ?? [];
      return Response.ok(jsonEncode(entries),
          headers: {'Content-Type': 'application/json'});
    });

    r.post('/', (Request request) async {
      final userId = request.context['userId'] as String;
      final body = jsonDecode(await request.readAsString());

      final entry = {
        'id': const Uuid().v4(),
        'courseCode': body['courseCode'],
        'title': body['title'],
        'dayOfWeek': body['dayOfWeek'], // 1-7
        'startTime': body['startTime'], // HH:mm
        'endTime': body['endTime'],
        'locationPinId': body['locationPinId'],
        'isRecurring': body['isRecurring'] ?? true,
      };

      _timetables.putIfAbsent(userId, () => []);
      _timetables[userId]!.add(entry);

      return Response.ok(jsonEncode(entry),
          headers: {'Content-Type': 'application/json'});
    });

    r.delete('/<id>', (Request request, String id) {
      final userId = request.context['userId'] as String;
      _timetables[userId]?.removeWhere((e) => e['id'] == id);
      return Response.ok(jsonEncode({'deleted': true}));
    });

    return r;
  }
}
