import 'package:postgres/postgres.dart';
import 'package:dotenv/dotenv.dart';

class Database {
  static Connection? _connection;

  static Future<Connection> get connection async {
    if (_connection != null && _connection!.isOpen) {
      return _connection!;
    }

    final env = DotEnv(includePlatformEnvironment: true)..load();
    final uri = Uri.parse(env['DATABASE_URL'] ?? 'postgres://postgres:password@localhost:5432/campuscash');

    _connection = await Connection.open(
      Endpoint(
        host: uri.host,
        port: uri.port,
        database: uri.pathSegments.isNotEmpty ? uri.pathSegments.first : 'campuscash',
        username: uri.userInfo.split(':').first,
        password: uri.userInfo.contains(':') ? uri.userInfo.split(':').last : null,
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );

    return _connection!;
  }

  static Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }

  /// Run all migrations / create tables
  static Future<void> migrate() async {
    final conn = await connection;

    await conn.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        display_name TEXT,
        photo_url TEXT,
        university_id TEXT,
        university_name TEXT,
        is_verified_student BOOLEAN DEFAULT FALSE,
        rating DOUBLE PRECISION DEFAULT 0,
        completed_gigs INT DEFAULT 0,
        fcm_token TEXT,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );

      CREATE TABLE IF NOT EXISTS map_pins (
        id UUID PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        lat DOUBLE PRECISION NOT NULL,
        lng DOUBLE PRECISION NOT NULL,
        is_free BOOLEAN DEFAULT TRUE,
        price DOUBLE PRECISION,
        category TEXT DEFAULT 'other',
        photos TEXT[] DEFAULT '{}',
        created_by UUID REFERENCES users(id),
        university_id TEXT NOT NULL,
        rating DOUBLE PRECISION DEFAULT 0,
        visit_count INT DEFAULT 0,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );

      CREATE TABLE IF NOT EXISTS gigs (
        id UUID PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        type TEXT NOT NULL,
        budget DOUBLE PRECISION NOT NULL,
        currency TEXT DEFAULT 'NGN',
        posted_by UUID REFERENCES users(id),
        course_code TEXT,
        university_id TEXT,
        status TEXT DEFAULT 'open',
        deadline TIMESTAMPTZ,
        tags TEXT[] DEFAULT '{}',
        word_count INT,
        academic_level TEXT,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );

      CREATE TABLE IF NOT EXISTS timetable_entries (
        id UUID PRIMARY KEY,
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        course_code TEXT,
        title TEXT,
        day_of_week INT,
        start_time TEXT,
        end_time TEXT,
        location_pin_id UUID REFERENCES map_pins(id),
        is_recurring BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );

      CREATE TABLE IF NOT EXISTS tours (
        id UUID PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        pin_ids UUID[] DEFAULT '{}',
        estimated_minutes INT DEFAULT 30,
        is_official BOOLEAN DEFAULT FALSE,
        cover_image TEXT,
        university_id TEXT NOT NULL,
        created_by UUID REFERENCES users(id),
        created_at TIMESTAMPTZ DEFAULT NOW()
      );

      CREATE TABLE IF NOT EXISTS wallets (
        user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
        balance DOUBLE PRECISION DEFAULT 0 CHECK (balance >= 0),
        currency TEXT DEFAULT 'NGN',
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );

      CREATE TABLE IF NOT EXISTS transactions (
        id UUID PRIMARY KEY,
        user_id UUID REFERENCES users(id),
        type TEXT NOT NULL,
        amount DOUBLE PRECISION NOT NULL,
        currency TEXT DEFAULT 'NGN',
        status TEXT DEFAULT 'pending',
        reference TEXT UNIQUE,
        paystack_reference TEXT,
        description TEXT,
        metadata JSONB,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );

      CREATE INDEX IF NOT EXISTS idx_map_pins_university ON map_pins(university_id);
      CREATE INDEX IF NOT EXISTS idx_gigs_type ON gigs(type);
      CREATE INDEX IF NOT EXISTS idx_gigs_university ON gigs(university_id);
      CREATE INDEX IF NOT EXISTS idx_transactions_user ON transactions(user_id);
    ''');

    print('Database migrated successfully');
  }
}
