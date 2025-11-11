import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../data/pet_repository.dart';
import '../models/pet.dart';
import '../models/pet_event.dart';

class PetController extends ChangeNotifier {
  PetController({
    PetRepository? repository,
    bool loadSampleData = true,
    String? documentsDirPath,
  })  : _repository = repository ?? SqlitePetRepository(),
        _loadSampleData = loadSampleData,
        _documentsDirPath = documentsDirPath ?? '' {
    _useCustomDocumentsDir = documentsDirPath != null;
    _initialization = _initialize();
  }

  final PetRepository _repository;
  final bool _loadSampleData;
  final List<Pet> _pets = [];
  final Uuid _uuid = const Uuid();
  bool _isLoading = true;
  late bool _useCustomDocumentsDir;
  String _documentsDirPath;
  late final Future<void> _initialization;

  bool get isLoading => _isLoading;
  List<Pet> get pets => List.unmodifiable(_pets);
  String get documentsDirPath => _documentsDirPath;

  Future<void> ensureInitialized() => _initialization;

  Pet? findById(String petId) {
    try {
      return _pets.firstWhere((pet) => pet.id == petId);
    } catch (_) {
      return null;
    }
  }

  List<PetEvent> eventsFor(String petId) {
    return List.unmodifiable(findById(petId)?.events ?? const []);
  }

  Future<void> addPet({
    required String name,
    required String type,
    String? breed,
    String? avatarAsset,
    String? avatarPath,
    DateTime? birthDate,
  }) async {
    final relativeAvatarPath = _toRelativePath(avatarPath);
    final storedPet = Pet(
      id: _uuid.v4(),
      name: name,
      type: type,
      breed: breed,
      avatarAsset: avatarAsset,
      avatarPath: relativeAvatarPath,
      birthDate: birthDate,
      events: const [],
    );

    await _repository.insertPet(storedPet);
    _pets.insert(
        0, storedPet.copyWith(avatarPath: _toAbsolutePath(relativeAvatarPath)));
    notifyListeners();
  }

  Future<void> addEvent({
    required String petId,
    required PetEvent event,
  }) async {
    final index = _pets.indexWhere((pet) => pet.id == petId);
    if (index == -1) return;

    await _repository.insertEvent(petId, event);

    final pet = _pets[index];
    final updatedEvents = List<PetEvent>.from(pet.events)
      ..add(event)
      ..sort(_sortEventsDesc);

    _pets[index] = pet.copyWith(events: updatedEvents);
    notifyListeners();
  }

  Future<void> updatePet({
    required String petId,
    String? name,
    String? type,
    String? breed,
    String? avatarAsset,
    String? avatarPath,
    DateTime? birthDate,
  }) async {
    final index = _pets.indexWhere((pet) => pet.id == petId);
    if (index == -1) return;

    final pet = _pets[index];
    final relativeAvatarPath = _toRelativePath(avatarPath ?? pet.avatarPath);
    final updatedStored = pet.copyWith(
      name: name ?? pet.name,
      type: type ?? pet.type,
      breed: breed ?? pet.breed,
      avatarPath: relativeAvatarPath,
      avatarAsset: avatarAsset ?? (avatarPath != null ? null : pet.avatarAsset),
      birthDate: birthDate ?? pet.birthDate,
    );

    await _repository.updatePet(updatedStored);
    _pets[index] = updatedStored.copyWith(
      avatarPath: _toAbsolutePath(relativeAvatarPath),
    );
    notifyListeners();
  }

  Future<void> removePet(String petId) async {
    await _repository.deletePet(petId);
    _pets.removeWhere((pet) => pet.id == petId);
    notifyListeners();
  }

  Future<void> updateEvent({
    required String petId,
    required PetEvent updatedEvent,
  }) async {
    final petIndex = _pets.indexWhere((pet) => pet.id == petId);
    if (petIndex == -1) return;

    await _repository.updateEvent(petId, updatedEvent);

    final pet = _pets[petIndex];
    final events = List<PetEvent>.from(pet.events);
    final eventIndex =
        events.indexWhere((event) => event.id == updatedEvent.id);
    if (eventIndex == -1) return;

    events[eventIndex] = updatedEvent;
    events.sort(_sortEventsDesc);

    _pets[petIndex] = pet.copyWith(events: events);
    notifyListeners();
  }

  Future<void> removeEvent({
    required String petId,
    required String eventId,
  }) async {
    final petIndex = _pets.indexWhere((pet) => pet.id == petId);
    if (petIndex == -1) return;

    await _repository.deleteEvent(eventId);

    final pet = _pets[petIndex];
    final events = List<PetEvent>.from(pet.events)
      ..removeWhere((event) => event.id == eventId);

    _pets[petIndex] = pet.copyWith(events: events);
    notifyListeners();
  }

  Future<void> _initialize() async {
    if (_documentsDirPath.isEmpty && !_useCustomDocumentsDir) {
      final documentsDir = await getApplicationDocumentsDirectory();
      _documentsDirPath = documentsDir.path;
    }
    await _repository.init();
    await _refreshFromRepository();
  }

  Future<void> _refreshFromRepository() async {
    final storedPets = await _repository.fetchPets();

    if (_loadSampleData && storedPets.isEmpty) {
      await _seedSampleData();
      return;
    }

    _pets
      ..clear()
      ..addAll(
        storedPets.map(
          (pet) => pet.copyWith(
            avatarPath: _toAbsolutePath(pet.avatarPath),
          ),
        ),
      );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _seedSampleData() async {
    final samples = _buildSamplePets();
    for (final pet in samples) {
      await _repository.insertPet(pet);
    }
    await _refreshFromRepository();
  }

  List<Pet> _buildSamplePets() {
    final now = DateTime.now();
    return [
      Pet(
        id: _uuid.v4(),
        name: 'Luna',
        type: 'Gata',
        breed: 'Siamês',
        birthDate: DateTime(2021, 6, 15),
        events: [
          PetEvent(
            id: _uuid.v4(),
            type: PetEventType.vaccine,
            date: now.subtract(const Duration(days: 45)),
            note: 'Vacina V8 anual',
            reminderDate: now.add(const Duration(days: 320)),
            services: const ['V8/V10 (Polivalente)'],
          ),
          PetEvent(
            id: _uuid.v4(),
            type: PetEventType.bath,
            date: now.subtract(const Duration(days: 10)),
            note: 'Banho com hidratação',
            services: const ['Banho tradicional', 'Hidratação'],
          ),
        ],
      ),
      Pet(
        id: _uuid.v4(),
        name: 'Thor',
        type: 'Cachorro',
        breed: 'Labrador',
        birthDate: DateTime(2019, 2, 2),
        events: [
          PetEvent(
            id: _uuid.v4(),
            type: PetEventType.vetVisit,
            date: now.subtract(const Duration(days: 75)),
            note: 'Check-up anual',
            reminderDate: now.add(const Duration(days: 290)),
            services: const ['Check-up'],
          ),
          PetEvent(
            id: _uuid.v4(),
            type: PetEventType.deworming,
            date: now.subtract(const Duration(days: 60)),
            reminderDate: now.add(const Duration(days: 120)),
            services: const ['Dose oral'],
          ),
        ],
      ),
      Pet(
        id: _uuid.v4(),
        name: 'Mel',
        type: 'Cachorro',
        breed: 'Golden Retriever',
        birthDate: DateTime(2020, 10, 5),
        events: [
          PetEvent(
            id: _uuid.v4(),
            type: PetEventType.grooming,
            date: now.subtract(const Duration(days: 20)),
            note: 'Tosa higiênica',
            reminderDate: now.add(const Duration(days: 40)),
            services: const ['Tosa higiênica'],
          ),
        ],
      ),
    ];
  }

  int _sortEventsDesc(PetEvent a, PetEvent b) => b.date.compareTo(a.date);

  String? _toRelativePath(String? path) {
    if (path == null || path.isEmpty) return path;
    if (path.startsWith('assets/')) return path;
    if (_documentsDirPath.isEmpty) return path;
    if (path.startsWith(_documentsDirPath)) {
      final relative = path.substring(_documentsDirPath.length);
      return relative.startsWith('/') ? relative.substring(1) : relative;
    }
    return path;
  }

  String? _toAbsolutePath(String? path) {
    if (path == null || path.isEmpty) return path;
    if (path.startsWith('/')) return path;
    if (_documentsDirPath.isEmpty) return path;
    return p.join(_documentsDirPath, path);
  }
}
