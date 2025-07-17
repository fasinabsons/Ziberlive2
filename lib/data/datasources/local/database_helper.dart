import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _databaseName = 'ziberlive.db';
  static const int _databaseVersion = 1;

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create apartments table
    await db.execute('''
      CREATE TABLE apartments (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        admin_ids_json TEXT NOT NULL,
        member_ids_json TEXT NOT NULL,
        settings_json TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        role TEXT NOT NULL CHECK (role IN ('user', 'roommate_admin')),
        apartment_id TEXT NOT NULL,
        room_id TEXT,
        bed_id TEXT,
        subscriptions_json TEXT NOT NULL,
        co_living_credits INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        last_sync_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (apartment_id) REFERENCES apartments(id)
      )
    ''');

    // Create bills table
    await db.execute('''
      CREATE TABLE bills (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        apartment_id TEXT NOT NULL,
        created_by TEXT NOT NULL,
        split_user_ids_json TEXT NOT NULL,
        payment_statuses_json TEXT NOT NULL,
        due_date DATETIME NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        is_recurring BOOLEAN DEFAULT FALSE,
        recurrence_pattern_json TEXT,
        FOREIGN KEY (apartment_id) REFERENCES apartments(id),
        FOREIGN KEY (created_by) REFERENCES users(id)
      )
    ''');

    // Create tasks table
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        apartment_id TEXT NOT NULL,
        assigned_to TEXT NOT NULL,
        created_by TEXT NOT NULL,
        due_date DATETIME NOT NULL,
        status TEXT DEFAULT 'pending',
        credits_reward INTEGER DEFAULT 5,
        type TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        completed_at DATETIME,
        FOREIGN KEY (apartment_id) REFERENCES apartments(id),
        FOREIGN KEY (assigned_to) REFERENCES users(id),
        FOREIGN KEY (created_by) REFERENCES users(id)
      )
    ''');

    // Create investment groups table
    await db.execute('''
      CREATE TABLE investment_groups (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        apartment_id TEXT NOT NULL,
        participant_ids_json TEXT NOT NULL,
        contributions_json TEXT NOT NULL,
        total_contributions REAL DEFAULT 0,
        current_value REAL DEFAULT 0,
        monthly_returns REAL DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (apartment_id) REFERENCES apartments(id)
      )
    ''');

    // Create investments table
    await db.execute('''
      CREATE TABLE investments (
        id TEXT PRIMARY KEY,
        group_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        expected_return REAL NOT NULL,
        status TEXT NOT NULL,
        investment_date DATETIME NOT NULL,
        maturity_date DATETIME,
        proposed_by TEXT NOT NULL,
        FOREIGN KEY (group_id) REFERENCES investment_groups(id),
        FOREIGN KEY (proposed_by) REFERENCES users(id)
      )
    ''');

    // Create votes table
    await db.execute('''
      CREATE TABLE votes (
        id TEXT PRIMARY KEY,
        question TEXT NOT NULL,
        options_json TEXT NOT NULL,
        votes_json TEXT NOT NULL,
        is_anonymous BOOLEAN DEFAULT FALSE,
        deadline DATETIME NOT NULL,
        apartment_id TEXT NOT NULL,
        created_by TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (apartment_id) REFERENCES apartments(id),
        FOREIGN KEY (created_by) REFERENCES users(id)
      )
    ''');

    // Create sync log table
    await db.execute('''
      CREATE TABLE sync_log (
        id TEXT PRIMARY KEY,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        operation TEXT NOT NULL CHECK (operation IN ('create', 'update', 'delete')),
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        device_id TEXT NOT NULL,
        synced BOOLEAN DEFAULT FALSE,
        conflict_resolved BOOLEAN DEFAULT TRUE
      )
    ''');

    // Create devices table
    await db.execute('''
      CREATE TABLE devices (
        id TEXT PRIMARY KEY,
        device_name TEXT NOT NULL,
        last_seen DATETIME DEFAULT CURRENT_TIMESTAMP,
        is_trusted BOOLEAN DEFAULT FALSE,
        apartment_id TEXT NOT NULL,
        sync_capabilities_json TEXT NOT NULL
      )
    ''');

    // Create indexes for performance
    await db.execute('CREATE INDEX idx_users_apartment_id ON users(apartment_id)');
    await db.execute('CREATE INDEX idx_bills_apartment_id ON bills(apartment_id)');
    await db.execute('CREATE INDEX idx_tasks_apartment_id ON tasks(apartment_id)');
    await db.execute('CREATE INDEX idx_tasks_assigned_to ON tasks(assigned_to)');
    await db.execute('CREATE INDEX idx_sync_log_synced ON sync_log(synced)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    // For now, we'll just recreate the database
    if (oldVersion < newVersion) {
      // Drop all tables and recreate
      await db.execute('DROP TABLE IF EXISTS devices');
      await db.execute('DROP TABLE IF EXISTS sync_log');
      await db.execute('DROP TABLE IF EXISTS votes');
      await db.execute('DROP TABLE IF EXISTS investments');
      await db.execute('DROP TABLE IF EXISTS investment_groups');
      await db.execute('DROP TABLE IF EXISTS tasks');
      await db.execute('DROP TABLE IF EXISTS bills');
      await db.execute('DROP TABLE IF EXISTS users');
      await db.execute('DROP TABLE IF EXISTS apartments');
      
      await _onCreate(db, newVersion);
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}