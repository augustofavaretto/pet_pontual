import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/pet.dart';
import '../models/pet_event.dart';

abstract class PetRepository {
  Future<void> init();

  Future<List<Pet>> fetchPets();

  Future<void> insertPet(Pet pet);

  Future<void> updatePet(Pet pet);

  Future<void> deletePet(String petId);

  Future<void> insertEvent(String petId, PetEvent event);

  Future<void> updateEvent(String petId, PetEvent event);

  Future<void> deleteEvent(String eventId);
}

class SqlitePetRepository implements PetRepository {
  SqlitePetRepository({String? databaseName})
      : _databaseName = databaseName ?? 'pet_pontual.db';

  final String _databaseName;
  Database? _db;

  Future<Database> _ensureDb() async {
    if (_db != null) return _db!;

    final basePath = await getDatabasesPath();
    final path = p.join(basePath, _databaseName);

    _db = await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pets(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            breed TEXT,
            avatar_asset TEXT,
            avatar_path TEXT,
            birth_date INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE events(
            id TEXT PRIMARY KEY,
            pet_id TEXT NOT NULL,
            type TEXT NOT NULL,
            date INTEGER NOT NULL,
            note TEXT,
            reminder_date INTEGER,
            services TEXT,
            FOREIGN KEY(pet_id) REFERENCES pets(id) ON DELETE CASCADE
          )
        ''');
      },
    );

    return _db!;
  }

  @override
  Future<void> init() async {
    await _ensureDb();
  }

  @override
  Future<List<Pet>> fetchPets() async {
    final db = await _ensureDb();
    final petsRows = await db.query('pets', orderBy: 'name COLLATE NOCASE');
    final eventsRows = await db.query('events', orderBy: 'date DESC');

    final eventsByPet = <String, List<PetEvent>>{};
    for (final row in eventsRows) {
      final petId = row['pet_id'] as String;
      final event = _eventFromMap(row);
      eventsByPet.putIfAbsent(petId, () => []).add(event);
    }

    return petsRows
        .map(
          (row) => Pet.fromMap(
            row,
            eventsByPet[row['id'] as String] ?? const [],
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> insertPet(Pet pet) async {
    final db = await _ensureDb();
    await db.insert(
      'pets',
      pet.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    for (final event in pet.events) {
      await insertEvent(pet.id, event);
    }
  }

  @override
  Future<void> updatePet(Pet pet) async {
    final db = await _ensureDb();
    await db.update(
      'pets',
      pet.toMap(),
      where: 'id = ?',
      whereArgs: [pet.id],
    );
  }

  @override
  Future<void> deletePet(String petId) async {
    final db = await _ensureDb();
    await db.delete('pets', where: 'id = ?', whereArgs: [petId]);
  }

  @override
  Future<void> insertEvent(String petId, PetEvent event) async {
    final db = await _ensureDb();
    await db.insert(
      'events',
      _eventToMap(petId, event),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateEvent(String petId, PetEvent event) async {
    final db = await _ensureDb();
    await db.update(
      'events',
      _eventToMap(petId, event),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    final db = await _ensureDb();
    await db.delete('events', where: 'id = ?', whereArgs: [eventId]);
  }

  Map<String, dynamic> _eventToMap(String petId, PetEvent event) =>
      event.toMap(petId);

  PetEvent _eventFromMap(Map<String, Object?> map) => PetEvent.fromMap(map);
}
