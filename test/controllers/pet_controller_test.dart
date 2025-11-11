import 'package:flutter_test/flutter_test.dart';

import 'package:pet_pontual/controllers/pet_controller.dart';
import 'package:pet_pontual/data/pet_repository.dart';
import 'package:pet_pontual/models/pet.dart';
import 'package:pet_pontual/models/pet_event.dart';

void main() {
  late _MemoryPetRepository repository;
  late PetController controller;

  setUp(() async {
    repository = _MemoryPetRepository();
    controller = PetController(
      repository: repository,
      loadSampleData: false,
      documentsDirPath: '/tmp',
    );
    await controller.ensureInitialized();
  });

  test('addPet persiste e expõe o novo pet', () async {
    expect(controller.pets, isEmpty);

    await controller.addPet(name: 'Luna', type: 'Gata');

    expect(controller.pets, hasLength(1));
    final storedPet = repository.pets.values.single;
    expect(storedPet.name, 'Luna');
    expect(storedPet.type, 'Gata');
  });

  test('updatePet atualiza dados locais e persistidos', () async {
    await controller.addPet(name: 'Thor', type: 'Cachorro');
    final petId = controller.pets.single.id;

    await controller.updatePet(petId: petId, name: 'Thor atualizado');

    expect(controller.pets.single.name, 'Thor atualizado');
    expect(repository.pets[petId]?.name, 'Thor atualizado');
  });

  test('addEvent adiciona evento ordenado por data', () async {
    await controller.addPet(name: 'Mel', type: 'Cachorro');
    final petId = controller.pets.single.id;

    final older = PetEvent(
      id: 'event_1',
      type: PetEventType.bath,
      date: DateTime(2024, 1, 1),
      services: const [],
    );
    final newer = PetEvent(
      id: 'event_2',
      type: PetEventType.grooming,
      date: DateTime(2024, 2, 1),
      services: const [],
    );

    await controller.addEvent(petId: petId, event: older);
    await controller.addEvent(petId: petId, event: newer);

    final events = controller.eventsFor(petId);
    expect(events, hasLength(2));
    expect(events.first.id, newer.id);
    expect(repository.pets[petId]?.events.first.id, newer.id);
  });
}

class _MemoryPetRepository implements PetRepository {
  final Map<String, Pet> pets = {};

  @override
  Future<void> init() async {}

  @override
  Future<List<Pet>> fetchPets() async =>
      pets.values.map((pet) => pet.copyWith(events: List.of(pet.events))).toList();

  @override
  Future<void> insertPet(Pet pet) async {
    pets[pet.id] = pet;
  }

  @override
  Future<void> updatePet(Pet pet) async {
    pets[pet.id] = pet;
  }

  @override
  Future<void> deletePet(String petId) async {
    pets.remove(petId);
  }

  @override
  Future<void> insertEvent(String petId, PetEvent event) async {
    final existing = pets[petId];
    if (existing == null) return;
    final updated = List<PetEvent>.from(existing.events)
      ..add(event)
      ..sort((a, b) => b.date.compareTo(a.date));
    pets[petId] = existing.copyWith(events: updated);
  }

  @override
  Future<void> updateEvent(String petId, PetEvent event) async {
    final existing = pets[petId];
    if (existing == null) return;
    final updated = existing.events
        .map((current) => current.id == event.id ? event : current)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    pets[petId] = existing.copyWith(events: updated);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    for (final entry in pets.entries) {
      final updated = List<PetEvent>.from(entry.value.events)
        ..removeWhere((event) => event.id == eventId);
      pets[entry.key] = entry.value.copyWith(events: updated);
    }
  }
}
