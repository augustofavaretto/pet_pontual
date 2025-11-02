import 'package:flutter/foundation.dart';

import '../models/pet.dart';
import '../models/pet_event.dart';

class PetController extends ChangeNotifier {
  PetController() {
    _initializeSamplePets();
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

    _pets[index] = pet.copyWith(events: updatedEvents);
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
            type: PetEventType.vaccine,
            date: DateTime.now().subtract(const Duration(days: 45)),
            note: 'Vacina V8 anual',
            reminderDate: DateTime.now().add(const Duration(days: 320)),
          ),
          PetEvent(
            type: PetEventType.bath,
            date: DateTime.now().subtract(const Duration(days: 10)),
            note: 'Banho com hidratação',
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
            type: PetEventType.vetVisit,
            date: DateTime.now().subtract(const Duration(days: 75)),
            note: 'Check-up anual',
            reminderDate: DateTime.now().add(const Duration(days: 290)),
          ),
          PetEvent(
            type: PetEventType.deworming,
            date: DateTime.now().subtract(const Duration(days: 60)),
            reminderDate: DateTime.now().add(const Duration(days: 120)),
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
            type: PetEventType.grooming,
            date: DateTime.now().subtract(const Duration(days: 20)),
            note: 'Tosa higiênica',
            reminderDate: DateTime.now().add(const Duration(days: 40)),
          ),
        ],
      ),
    ]);
  }

  String _nextId() {
    _idCounter += 1;
    return 'pet_$_idCounter';
  }
}
