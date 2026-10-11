import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';
import '../models/gig.dart';

class GigRoutes {
  static final List<Map<String, dynamic>> _gigs = [];

  Router get router {
    final r = Router();

    // List gigs (filter by type, university, course)
    r.get('/', (Request request) {
      final type = request.url.queryParameters['type'];
      final universityId = request.url.queryParameters['universityId'];

      var filtered = _gigs;
      if (type != null) {
        filtered = filtered.where((g) => g['type'] == type).toList();
      }
      if (universityId != null) {
        filtered = filtered.where((g) => g['universityId'] == universityId).toList();
      }

      return Response.ok(jsonEncode(filtered),
          headers: {'Content-Type': 'application/json'});
    });

    // Create gig (including projectWriting)
    r.post('/', (Request request) async {
      final userId = request.context['userId'] as String;
      final body = jsonDecode(await request.readAsString());

      final typeStr = body['type'] as String? ?? 'campusGig';
      final gig = {
        'id': const Uuid().v4(),
        'title': body['title'],
        'description': body['description'],
        'type': typeStr, // microTask | tutoring | notes | campusGig | projectWriting | skillGig
        'budget': body['budget'],
        'currency': body['currency'] ?? 'USD',
        'postedBy': userId,
        'courseCode': body['courseCode'],
        'universityId': body['universityId'],
        'status': 'open',
        'deadline': body['deadline'],
        'tags': body['tags'] ?? [],
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      };

      _gigs.add(gig);
      return Response.ok(jsonEncode(gig),
          headers: {'Content-Type': 'application/json'});
    });

    // Project Writing specific endpoint (convenience)
    r.post('/project-writing', (Request request) async {
      final userId = request.context['userId'] as String;
      final body = jsonDecode(await request.readAsString());

      final gig = {
        'id': const Uuid().v4(),
        'title': body['title'] ?? 'Project Writing Request',
        'description': body['description'],
        'type': 'projectWriting',
        'budget': body['budget'],
        'currency': body['currency'] ?? 'USD',
        'postedBy': userId,
        'courseCode': body['courseCode'],
        'universityId': body['universityId'],
        'status': 'open',
        'deadline': body['deadline'],
        'tags': ['project-writing', 'essay', 'report', ...(body['tags'] ?? [])],
        'wordCount': body['wordCount'],
        'academicLevel': body['academicLevel'], // undergrad, masters, etc.
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      };

      _gigs.add(gig);
      return Response.ok(jsonEncode(gig),
          headers: {'Content-Type': 'application/json'});
    });

    return r;
  }
}
