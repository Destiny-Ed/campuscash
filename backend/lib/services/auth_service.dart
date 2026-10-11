import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../db/database.dart';

class AuthService {
  final String _jwtSecret;

  AuthService() : _jwtSecret = (DotEnv(includePlatformEnvironment: true)..load())['JWT_SECRET'] ?? 'dev-secret';

  Future<Map<String, dynamic>> verifyGoogleIdToken(String idToken) async {
    final res = await http.get(Uri.parse('https://oauth2.googleapis.com/tokeninfo?id_token=$idToken'));
    if (res.statusCode != 200) {
      throw Exception('Invalid Google idToken');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  String generateJwt(String userId, String email) {
    final jwt = JWT({
      'sub': userId,
      'email': email,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    });
    return jwt.sign(SecretKey(_jwtSecret), expiresIn: const Duration(days: 30));
  }

  Map<String, dynamic>? verifyJwt(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_jwtSecret));
      return jwt.payload as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle({
    required String idToken,
    String? fcmToken,
  }) async {
    final payload = await verifyGoogleIdToken(idToken);
    final email = payload['email'] as String;
    final name = payload['name'] as String? ?? email.split('@').first;
    final picture = payload['picture'] as String?;

    final conn = await Database.connection;

    final existing = await conn.execute(
      Sql.named('SELECT * FROM users WHERE email = @email'),
      parameters: {'email': email},
    );

    String userId;
    Map<String, dynamic> user;

    if (existing.isEmpty) {
      userId = const Uuid().v4();
      await conn.execute(
        Sql.named('''
          INSERT INTO users (id, email, display_name, photo_url, fcm_token)
          VALUES (@id, @email, @name, @photo, @fcm)
        '''),
        parameters: {
          'id': userId,
          'email': email,
          'name': name,
          'photo': picture,
          'fcm': fcmToken,
        },
      );

      await conn.execute(
        Sql.named('INSERT INTO wallets (user_id, balance) VALUES (@id, 0)'),
        parameters: {'id': userId},
      );

      user = {
        'id': userId,
        'email': email,
        'displayName': name,
        'photoUrl': picture,
        'isVerifiedStudent': false,
      };
    } else {
      final row = existing.first.toColumnMap();
      userId = row['id'] as String;

      if (fcmToken != null) {
        await conn.execute(
          Sql.named('UPDATE users SET fcm_token = @fcm, updated_at = NOW() WHERE id = @id'),
          parameters: {'fcm': fcmToken, 'id': userId},
        );
      }

      user = {
        'id': userId,
        'email': row['email'],
        'displayName': row['display_name'],
        'photoUrl': row['photo_url'],
        'university': row['university_name'],
        'isVerifiedStudent': row['is_verified_student'] ?? false,
        'rating': row['rating'] ?? 0,
        'completedGigs': row['completed_gigs'] ?? 0,
      };
    }

    final token = generateJwt(userId, email);
    return {'token': token, 'user': user};
  }
}
