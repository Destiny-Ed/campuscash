import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';
import '../models/map_pin.dart';

class MapRoutes {
  // In-memory for demo — replace with real DB
  static final List<MapPin> _pins = [];

  Router get router {
    final r = Router();

    r.get('/pins/<universityId>', (Request request, String universityId) {
      final pins = _pins.where((p) => p.universityId == universityId).toList();
      return Response.ok(jsonEncode(pins.map((p) => p.toJson()).toList()),
          headers: {'Content-Type': 'application/json'});
    });

    r.post('/pins', (Request request) async {
      final userId = request.context['userId'] as String;
      final body = jsonDecode(await request.readAsString());

      final pin = MapPin(
        id: const Uuid().v4(),
        title: body['title'],
        description: body['description'] ?? '',
        lat: (body['lat'] as num).toDouble(),
        lng: (body['lng'] as num).toDouble(),
        isFree: body['isFree'] ?? true,
        price: body['price'] != null ? (body['price'] as num).toDouble() : null,
        category: body['category'] ?? 'other',
        photos: List<String>.from(body['photos'] ?? []),
        createdBy: userId,
        universityId: body['universityId'],
        createdAt: DateTime.now().toUtc(),
      );

      _pins.add(pin);
      return Response.ok(jsonEncode(pin.toJson()),
          headers: {'Content-Type': 'application/json'});
    });

    r.get('/pins/detail/<id>', (Request request, String id) {
      final pin = _pins.where((p) => p.id == id).firstOrNull;
      if (pin == null) return Response.notFound('Pin not found');
      return Response.ok(jsonEncode(pin.toJson()),
          headers: {'Content-Type': 'application/json'});
    });

    return r;
  }
}
