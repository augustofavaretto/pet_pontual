import 'package:flutter/foundation.dart';

import '../models/pet.dart';
import '../models/pet_event.dart';

class PetController extends ChangeNotifier {
  PetController({bool loadSampleData = true}) {
    if (loadSampleData) {
      _initializeSamplePets();
    }
  }

  final List<Pet> _pets = [];
  int _idCounter = 0;

  List<Pet> get pets => List.unmodifiable(_pets);

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

  void addPet({
    required String name,
    required String type,
    String? breed,
    String? avatarAsset,
    String? avatarPath,
    DateTime? birthDate,
  }) {
    final pet = Pet(
      id: _nextId(),
      name: name,
      type: type,
      breed: breed,
      avatarAsset: avatarAsset,
      avatarPath: avatarPath,
      birthDate: birthDate,
      events: const [],
    );

    _pets.insert(0, pet);
    notifyListeners();
  }

  void addEvent({
    required String petId,
    required PetEvent event,
  }) {
    final index = _pets.indexWhere((pet) => pet.id == petId);
    if (index == -1) return;

    final pet = _pets[index];
    final updatedEvents = List<PetEvent>.from(pet.events)..add(event);
    updatedEvents.sort(_sortEventsDescending);

    _pets[index] = pet.copyWith(events: updatedEvents);
    notifyListeners();
  }

  void updateEvent({
    required String petId,
    required String eventId,
    PetEventType? type,
    DateTime? date,
    String? note,
    DateTime? reminderDate,
    List<String>? services,
  }) {
    final petIndex = _pets.indexWhere((pet) => pet.id == petId);
    if (petIndex == -1) return;

    final pet = _pets[petIndex];
    final events = List<PetEvent>.from(pet.events);
    final eventIndex = events.indexWhere((event) => event.id == eventId);
    if (eventIndex == -1) return;

    final event = events[eventIndex];
    events[eventIndex] = event.copyWith(
      type: type,
      date: date,
      note: note,
      reminderDate: reminderDate,
      services: services,
    );
    events.sort(_sortEventsDescending);

    _pets[petIndex] = pet.copyWith(events: events);
    notifyListeners();
  }

  void removeEvent({
    required String petId,
    required String eventId,
  }) {
    final petIndex = _pets.indexWhere((pet) => pet.id == petId);
    if (petIndex == -1) return;

    final pet = _pets[petIndex];
    final events = List<PetEvent>.from(pet.events)
      ..removeWhere((event) => event.id == eventId);

    _pets[petIndex] = pet.copyWith(events: events);
    notifyListeners();
  }

  void updatePet({
    required String petId,
    String? name,
    String? type,
    String? breed,
    String? avatarAsset,
    String? avatarPath,
    DateTime? birthDate,
  }) {
    final index = _pets.indexWhere((pet) => pet.id == petId);
    if (index == -1) return;

    final pet = _pets[index];
    _pets[index] = pet.copyWith(
      name: name ?? pet.name,
      type: type ?? pet.type,
      breed: breed ?? pet.breed,
      avatarPath: avatarPath ?? pet.avatarPath,
      avatarAsset: avatarAsset ?? (avatarPath != null ? null : pet.avatarAsset),
      birthDate: birthDate ?? pet.birthDate,
    );
    notifyListeners();
  }

  void removePet(String petId) {
    _pets.removeWhere((pet) => pet.id == petId);
    notifyListeners();
  }

  void _initializeSamplePets() {
    _pets.addAll([
      Pet(
        id: _nextId(),
        name: 'Luna',
        type: 'Gata',
        breed: 'Siamês',
        birthDate: DateTime(2021, 6, 15),
        events: [
          PetEvent(
            id: _nextEventId(),
            type: PetEventType.vaccine,
            date: DateTime.now().subtract(const Duration(days: 45)),
            note: 'Vacina V8 anual',
            reminderDate: DateTime.now().add(const Duration(days: 320)),
            services: const ['V8/V10 (Polivalente)'],
          ),
          PetEvent(
            id: _nextEventId(),
            type: PetEventType.bath,
            date: DateTime.now().subtract(const Duration(days: 10)),
            note: 'Banho com hidratação',
            services: const ['Banho tradicional', 'Hidratação'],
          ),
        ],
      ),
      Pet(
        id: _nextId(),
        name: 'Thor',
        type: 'Cachorro',
        breed: 'Labrador',
        birthDate: DateTime(2019, 2, 2),
        events: [
          PetEvent(
            id: _nextEventId(),
            type: PetEventType.vetVisit,
            date: DateTime.now().subtract(const Duration(days: 75)),
            note: 'Check-up anual',
            reminderDate: DateTime.now().add(const Duration(days: 290)),
            services: const ['Consulta geral'],
          ),
          PetEvent(
            id: _nextEventId(),
            type: PetEventType.deworming,
            date: DateTime.now().subtract(const Duration(days: 60)),
            reminderDate: DateTime.now().add(const Duration(days: 120)),
            services: const ['Vermífugo oral'],
          ),
        ],
      ),
      Pet(
        id: _nextId(),
        name: 'Mel',
        type: 'Cachorro',
        breed: 'Golden Retriever',
        birthDate: DateTime(2020, 10, 5),
        events: [
          PetEvent(
            id: _nextEventId(),
            type: PetEventType.grooming,
            date: DateTime.now().subtract(const Duration(days: 20)),
            note: 'Tosa higiênica',
            reminderDate: DateTime.now().add(const Duration(days: 40)),
            services: const ['Tosa higiênica'],
          ),
        ],
      ),
    ]);
  }

  String _nextId() {
    _idCounter += 1;
    return 'pet_$_idCounter';
  }

  int _eventCounter = 0;

  String _nextEventId() {
    _eventCounter += 1;
    return 'event_$_eventCounter';
  }

  int _sortEventsDescending(PetEvent a, PetEvent b) {
    return b.date.compareTo(a.date);
  }
}
