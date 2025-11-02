import 'pet_event.dart';

class Pet {
  const Pet({
    required this.id,
    required this.name,
    required this.type,
    this.breed,
    this.avatarAsset,
    this.avatarPath,
    this.birthDate,
    this.events = const [],
  });

  final String id;
  final String name;
  final String type;
  final String? breed;
  final String? avatarAsset;
  final String? avatarPath;
  final DateTime? birthDate;
  final List<PetEvent> events;

  String get description => breed == null ? type : '$type · $breed';

  Pet copyWith({
    String? id,
    String? name,
    String? type,
    String? breed,
    String? avatarAsset,
    String? avatarPath,
    DateTime? birthDate,
    List<PetEvent>? events,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      avatarPath: avatarPath ?? this.avatarPath,
      birthDate: birthDate ?? this.birthDate,
      events: events ?? List<PetEvent>.from(this.events),
    );
  }
}
