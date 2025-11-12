import 'package:flutter_test/flutter_test.dart';
import 'package:pet_pontual/data/pet_repository.dart';
import 'package:pet_pontual/models/pet.dart';
import 'package:pet_pontual/models/pet_event.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('SqlitePetRepository', () {
    late SqlitePetRepository repository;

    setUp(() async {
      final dbName = 'test_${DateTime.now().microsecondsSinceEpoch}.db';
      repository = SqlitePetRepository(databaseName: dbName);
      await repository.init();
    });

    test('insertPet e fetchPets retornam pets com eventos associados', () async {
      final event = PetEvent(
        id: 'event_1',
        type: PetEventType.vaccine,
        date: DateTime(2024, 1, 10),
        note: 'Vacina anual',
        services: const ['V8'],
      );
      final pet = Pet(
        id: 'pet_1',
        name: 'Luna',
        type: 'Gata',
        breed: 'Siamês',
        events: [event],
      );

      await repository.insertPet(pet);

      final storedPets = await repository.fetchPets();

      expect(storedPets, hasLength(1));
      expect(storedPets.first.events, hasLength(1));
      expect(storedPets.first.events.first.type, PetEventType.vaccine);
      expect(storedPets.first.events.first.note, 'Vacina anual');
    });

    test('deletePet remove o pet e seus eventos', () async {
      final pet = Pet(
        id: 'pet_2',
        name: 'Thor',
        type: 'Cachorro',
        events: [
          PetEvent(
            id: 'event_2',
            type: PetEventType.bath,
            date: DateTime(2024, 2, 1),
            services: const [],
          ),
        ],
      );

      await repository.insertPet(pet);
      expect((await repository.fetchPets()), isNotEmpty);

      await repository.deletePet(pet.id);

      final remainingPets = await repository.fetchPets();
      expect(remainingPets, isEmpty);
    });
  });
}
