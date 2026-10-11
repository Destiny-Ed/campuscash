import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../db/database.dart';

class GigRoutes {
  Router get router {
    final r = Router();

    r.get('/', (Request request) async {
      final type = request.url.queryParameters['type'];
      final universityId = request.url.queryParameters['universityId'];
      final conn = await Database.connection;

      var query = '''
        SELECT id, title, description, type, budget, currency, posted_by,
               course_code, university_id, status, deadline, tags,
               word_count, academic_level, created_at
        FROM gigs WHERE status = 'open'
      ''';
      final params = <String, dynamic>{};

      if (type != null) {
        query += ' AND type = @type';
        params['type'] = type;
      }
      if (universityId != null) {
        query += ' AND university_id = @uni';
        params['uni'] = universityId;
      }

      query += ' ORDER BY created_at DESC LIMIT 50';

      final result = await conn.execute(Sql.named(query), parameters: params);

      final gigs = result.map((row) {
        final m = row.toColumnMap();
        return {
          'id': m['id'],
          'title': m['title'],
          'description': m['description'],
          'type': m['type'],
          'budget': m['budget'],
          'currency': m['currency'],
          'postedBy': m['posted_by'],
          'courseCode': m['course_code'],
          'universityId': m['university_id'],
          'status': m['status'],
          'deadline': m['deadline']?.toString(),
          'tags': m['tags'] ?? [],
          'wordCount': m['word_count'],
          'academicLevel': m['academic_level'],
          'createdAt': m['created_at']?.toString(),
        };
      }).toList();

      return Response.ok(jsonEncode(gigs),
          headers: {'Content-Type': 'application/json'});
    });

    r.post('/', (Request request) async {
      final userId = request.context['userId'] as String;
      final body = jsonDecode(await request.readAsString());
      final conn = await Database.connection;
      final id = const Uuid().v4();

      await conn.execute(
        Sql.named('''
          INSERT INTO gigs (id, title, description, type, budget, currency, posted_by,
                            course_code, university_id, deadline, tags, word_count, academic_level)
          VALUES (@id, @title, @desc, @type, @budget, @currency, @userId,
                  @course, @uni, @deadline, @tags, @words, @level)
        '''),
        parameters: {
          'id': id,
          'title': body['title'],
          'desc': body['description'],
          'type': body['type'] ?? 'campusGig',
          'budget': body['budget'],
          'currency': body['currency'] ?? 'NGN',
          'userId': userId,
          'course': body['courseCode'],
          'uni': body['universityId'],
          'deadline': body['deadline'],
          'tags': body['tags'] ?? [],
          'words': body['wordCount'],
          'level': body['academicLevel'],
        },
      );

      return Response.ok(jsonEncode({'id': id, ...body}),
          headers: {'Content-Type': 'application/json'});
    });

    // Dedicated Project Writing endpoint
    r.post('/project-writing', (Request request) async {
      final userId = request.context['userId'] as String;
      final body = jsonDecode(await request.readAsString());
      final conn = await Database.connection;
      final id = const Uuid().v4();

      await conn.execute(
        Sql.named('''
          INSERT INTO gigs (id, title, description, type, budget, currency, posted_by,
                            course_code, university_id, deadline, tags, word_count, academic_level)
          VALUES (@id, @title, @desc, 'projectWriting', @budget, @currency, @userId,
                  @course, @uni, @deadline, @tags, @words, @level)
        '''),
        parameters: {
          'id': id,
          'title': body['title'] ?? 'Project Writing Request',
          'desc': body['description'],
          'budget': body['budget'],
          'currency': body['currency'] ?? 'NGN',
          'userId': userId,
          'course': body['courseCode'],
          'uni': body['universityId'],
          'deadline': body['deadline'],
          'tags': ['project-writing', 'essay', 'report', ...(body['tags'] as List? ?? [])],
          'words': body['wordCount'],
          'level': body['academicLevel'],
        },
      );

      return Response.ok(
        jsonEncode({
          'id': id,
          'type': 'projectWriting',
          ...body,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    });

    return r;
  }
}
