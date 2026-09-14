import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/contact_model.dart';
import '../models/incident_model.dart';
import '../models/medical_profile_model.dart';

class LocalDb {
  static final LocalDb instance = LocalDb._init();
  static Database? _database;

  LocalDb._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nirapad_emergency.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Contacts table
    await db.execute('''
      CREATE TABLE contacts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        relation TEXT NOT NULL,
        is_primary INTEGER NOT NULL,
        can_receive_sms INTEGER NOT NULL,
        can_receive_call INTEGER NOT NULL
      )
    ''');

    // Incidents history table
    await db.execute('''
      CREATE TABLE incidents (
        id TEXT PRIMARY KEY,
        timestamp TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        address TEXT,
        mode TEXT NOT NULL,
        status TEXT NOT NULL,
        battery_level INTEGER NOT NULL,
        speed_kmh REAL NOT NULL,
        notes TEXT,
        is_duress_alarm INTEGER NOT NULL
      )
    ''');

    // Medical profile table
    await db.execute('''
      CREATE TABLE medical_profile (
        id INTEGER PRIMARY KEY,
        full_name TEXT,
        age INTEGER,
        blood_group TEXT,
        chronic_conditions TEXT,
        allergies TEXT,
        regular_medications TEXT,
        emergency_doctor_phone TEXT,
        preferred_hospital TEXT,
        is_organ_donor INTEGER
      )
    ''');

    // Insert default demo contacts and profile for Bangladesh emergency
    await db.insert('contacts', {
      'id': 'c1',
      'name': 'বাবা / মা (Primary Guardian)',
      'phone_number': '01700000000',
      'relation': 'প্যারেন্ট',
      'is_primary': 1,
      'can_receive_sms': 1,
      'can_receive_call': 1,
    });

    await db.insert('contacts', {
      'id': 'c2',
      'name': 'জাতীয় জরুরি সেবা (৯৯৯)',
      'phone_number': '999',
      'relation': 'জরুরি হেল্পলাইন',
      'is_primary': 0,
      'can_receive_sms': 0,
      'can_receive_call': 1,
    });

    await db.insert('medical_profile', {
      'id': 1,
      'full_name': 'ইউজার প্রোফাইল',
      'age': 25,
      'blood_group': 'B+',
      'chronic_conditions': 'নেই',
      'allergies': 'পেনিসিলিন',
      'regular_medications': 'নেই',
      'emergency_doctor_phone': '01800000000',
      'preferred_hospital': 'ঢাকা মেডিকেল কলেজ হাসপাতাল',
      'is_organ_donor': 1,
    });
  }

  // --- Contacts CRUD ---
  Future<List<ContactModel>> getContacts() async {
    final db = await database;
    final maps = await db.query('contacts', orderBy: 'is_primary DESC, name ASC');
    return maps.map((e) => ContactModel.fromMap(e)).toList();
  }

  Future<int> insertContact(ContactModel contact) async {
    final db = await database;
    return await db.insert(
      'contacts',
      contact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateContact(ContactModel contact) async {
    final db = await database;
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> deleteContact(String id) async {
    final db = await database;
    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Incidents CRUD ---
  Future<List<IncidentModel>> getIncidents() async {
    final db = await database;
    final maps = await db.query('incidents', orderBy: 'timestamp DESC');
    return maps.map((e) => IncidentModel.fromMap(e)).toList();
  }

  Future<int> insertIncident(IncidentModel incident) async {
    final db = await database;
    return await db.insert(
      'incidents',
      incident.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- Medical Profile CRUD ---
  Future<MedicalProfileModel> getMedicalProfile() async {
    final db = await database;
    final maps = await db.query('medical_profile', where: 'id = 1');
    if (maps.isNotEmpty) {
      return MedicalProfileModel.fromMap(maps.first);
    }
    return const MedicalProfileModel();
  }

  Future<int> saveMedicalProfile(MedicalProfileModel profile) async {
    final db = await database;
    final data = profile.toMap();
    data['id'] = 1;
    return await db.insert(
      'medical_profile',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
