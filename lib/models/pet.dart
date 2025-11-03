import 'pet_event.dart';

class PetFields {
  static const String id = 'id';
  static const String name = 'name';
  static const String type = 'type';
  static const String breed = 'breed';
  static const String avatarAsset = 'avatar_asset';
  static const String avatarPath = 'avatar_path';
  static const String birthDate = 'birth_date';
}

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

  Map<String, dynamic> toMap() {
    return {
      PetFields.id: id,
      PetFields.name: name,
      PetFields.type: type,
      PetFields.breed: breed,
      PetFields.avatarAsset: avatarAsset,
      PetFields.avatarPath: avatarPath,
      PetFields.birthDate: birthDate?.millisecondsSinceEpoch,
    };
  }

  factory Pet.fromMap(Map<String, Object?> map,
      [List<PetEvent> events = const []]) {
    return Pet(
      id: map[PetFields.id] as String,
      name: map[PetFields.name] as String,
      type: map[PetFields.type] as String,
      breed: map[PetFields.breed] as String?,
      avatarAsset: map[PetFields.avatarAsset] as String?,
      avatarPath: map[PetFields.avatarPath] as String?,
      birthDate: map[PetFields.birthDate] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              map[PetFields.birthDate] as int),
      events: events,
    );
  }
}
