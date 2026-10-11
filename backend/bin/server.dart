import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:dotenv/dotenv.dart';

import '../lib/routes/auth_routes.dart';
import '../lib/routes/map_routes.dart';
import '../lib/routes/gig_routes.dart';
import '../lib/routes/timetable_routes.dart';
import '../lib/routes/tour_routes.dart';
import '../lib/routes/wallet_routes.dart';
import '../lib/routes/user_routes.dart';
import '../lib/middleware/auth_middleware.dart';

void main(List<String> args) async {
  final env = DotEnv(includePlatformEnvironment: true)..load();
  final port = int.tryParse(env['PORT'] ?? '8080') ?? 8080;

  final router = Router();

  // Public routes
  router.mount('/api/auth/', AuthRoutes().router);

  // Protected routes
  final authed = Pipeline()
      .addMiddleware(authMiddleware())
      .addHandler((Request request) {
    final protected = Router();
    protected.mount('/api/map/', MapRoutes().router);
    protected.mount('/api/gigs/', GigRoutes().router);
    protected.mount('/api/timetable/', TimetableRoutes().router);
    protected.mount('/api/tours/', TourRoutes().router);
    protected.mount('/api/wallet/', WalletRoutes().router);
    protected.mount('/api/users/', UserRoutes().router);
    return protected.call(request);
  });

  router.mount('/', authed);

  router.get('/health', (Request request) {
    return Response.ok('CampusCash API is healthy');
  });

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
      }))
      .addHandler(router.call);

  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  print('CampusCash backend running on http://${server.address.host}:${server.port}');
}
