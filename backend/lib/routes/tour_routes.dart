import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

class TourRoutes {
  static final List<Map<String, dynamic>> _tours = [];

  Router get router {
    final r = Router();

    r.get('/<universityId>', (Request request, String universityId) {
      final tours = _tours.where((t) => t['universityId'] == universityId).toList();
      return Response.ok(jsonEncode(tours),
          headers: {'Content-Type': 'application/json'});
    });

    r.post('/', (Request request) async {
      final userId = request.context['userId'] as String;
      final body = jsonDecode(await request.readAsString());

      final tour = {
        'id': const Uuid().v4(),
        'title': body['title'],
        'description': body['description'],
        'pinIds': body['pinIds'] ?? [],
        'estimatedMinutes': body['estimatedMinutes'] ?? 30,
        'isOfficial': body['isOfficial'] ?? false,
        'coverImage': body['coverImage'],
        'universityId': body['universityId'],
        'createdBy': userId,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      };

      _tours.add(tour);
      return Response.ok(jsonEncode(tour),
          headers: {'Content-Type': 'application/json'});
    });

    return r;
  }
}
