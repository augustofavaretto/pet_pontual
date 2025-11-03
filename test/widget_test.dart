import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pet_pontual/main.dart';
import 'package:pet_pontual/controllers/pet_controller.dart';
import 'package:pet_pontual/models/pet.dart';
import 'package:pet_pontual/models/pet_event.dart';
import 'package:pet_pontual/screens/home_page.dart';
import 'package:provider/provider.dart';

import 'package:pet_pontual/data/pet_repository.dart' as pet_repository;

void main() {
  testWidgets('HomePage exibe lista de pets cadastrados',
      (WidgetTester tester) async {
    final repository = _FakePetRepository(initialPets: _samplePets);
    final controller = PetController(
      repository: repository,
      loadSampleData: false,
      documentsDirPath: '/tmp',
    );

    await controller.ensureInitialized();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Seus Pets'), findsOneWidget);
    expect(find.text('Luna'), findsOneWidget);
    expect(find.text('Thor'), findsOneWidget);
    expect(find.text('Mel'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(3));
  });

  testWidgets('HomePage mostra estado vazio quando não há pets',
      (WidgetTester tester) async {
    final repository = _FakePetRepository();
    final controller = PetController(
      repository: repository,
      loadSampleData: false,
      documentsDirPath: '/tmp',
    );
    await controller.ensureInitialized();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(home: HomePage()),
      ),
    );

    expect(find.text('Você ainda não cadastrou nenhum pet.'), findsOneWidget);
    expect(find.textContaining('Use o botão “+”'), findsOneWidget);
  });
}

class _FakePetRepository implements pet_repository.PetRepository {
  _FakePetRepository({List<Pet>? initialPets}) {
    if (initialPets != null) {
      for (final pet in initialPets) {
        _pets[pet.id] = pet;
      }
    }
  }

  final Map<String, Pet> _pets = {};

  @override
  Future<void> init() async {}

  @override
  Future<List<Pet>> fetchPets() async => _pets.values
      .map((pet) => pet.copyWith(events: List<PetEvent>.from(pet.events)))
      .toList(growable: false);

  @override
  Future<void> insertPet(Pet pet) async {
    _pets[pet.id] = pet;
  }

  @override
  Future<void> updatePet(Pet pet) async {
    _pets[pet.id] = pet;
  }

  @override
  Future<void> deletePet(String petId) async {
    _pets.remove(petId);
  }

  @override
  Future<void> insertEvent(String petId, PetEvent event) async {
    final pet = _pets[petId];
    if (pet == null) return;
    final events = List<PetEvent>.from(pet.events)..add(event);
    events.sort((a, b) => b.date.compareTo(a.date));
    _pets[petId] = pet.copyWith(events: events);
  }

  @override
  Future<void> updateEvent(String petId, PetEvent event) async {
    final pet = _pets[petId];
    if (pet == null) return;
    final events = pet.events
        .map((existing) => existing.id == event.id ? event : existing)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    _pets[petId] = pet.copyWith(events: events);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    for (final entry in _pets.entries) {
      final events = List<PetEvent>.from(entry.value.events)
        ..removeWhere((event) => event.id == eventId);
      _pets[entry.key] = entry.value.copyWith(events: events);
    }
  }
}

final List<Pet> _samplePets = [
  Pet(
    id: 'pet_1',
    name: 'Luna',
    type: 'Gata',
    breed: 'Siamês',
    birthDate: DateTime(2021, 6, 15),
    events: const [],
  ),
  Pet(
    id: 'pet_2',
    name: 'Thor',
    type: 'Cachorro',
    breed: 'Labrador',
    birthDate: DateTime(2019, 2, 2),
    events: const [],
  ),
  Pet(
    id: 'pet_3',
    name: 'Mel',
    type: 'Cachorro',
    breed: 'Golden Retriever',
    birthDate: DateTime(2020, 10, 5),
    events: const [],
  ),
];
