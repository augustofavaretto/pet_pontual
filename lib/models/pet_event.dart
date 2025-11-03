import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum PetEventType {
  vaccine,
  bath,
  deworming,
  grooming,
  feeding,
  vetVisit,
  other,
}

class PetEvent extends Equatable {
  const PetEvent({
    required this.id,
    required this.type,
    required this.date,
    this.note,
    this.reminderDate,
    this.services = const [],
  });

  final String id;
  final PetEventType type;
  final DateTime date;
  final String? note;
  final DateTime? reminderDate;
  final List<String> services;

  PetEvent copyWith({
    String? id,
    PetEventType? type,
    DateTime? date,
    String? note,
    DateTime? reminderDate,
    List<String>? services,
  }) {
    return PetEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
      reminderDate: reminderDate ?? this.reminderDate,
      services: services ?? List<String>.from(this.services),
    );
  }

  Map<String, dynamic> toMap(String petId) {
    return {
      'id': id,
      'pet_id': petId,
      'type': type.name,
      'date': date.millisecondsSinceEpoch,
      'note': note,
      'reminder_date': reminderDate?.millisecondsSinceEpoch,
      'services': jsonEncode(services),
    };
  }

  factory PetEvent.fromMap(Map<String, Object?> map) {
    final servicesRaw = map['services'] as String?;
    final List<String> services = servicesRaw == null
        ? const []
        : List<String>.from(jsonDecode(servicesRaw) as List<dynamic>);

    return PetEvent(
      id: map['id'] as String,
      type: PetEventTypeLabel.fromName(map['type'] as String),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      note: map['note'] as String?,
      reminderDate: map['reminder_date'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['reminder_date'] as int),
      services: services,
    );
  }

  @override
  List<Object?> get props => [id, type, date, note, reminderDate, services];
}

extension PetEventTypeLabel on PetEventType {
  String get label {
    switch (this) {
      case PetEventType.vaccine:
        return 'Vacina';
      case PetEventType.bath:
        return 'Banho';
      case PetEventType.deworming:
        return 'Vermífugo';
      case PetEventType.grooming:
        return 'Tosa';
      case PetEventType.feeding:
        return 'Alimentação';
      case PetEventType.vetVisit:
        return 'Consulta';
      case PetEventType.other:
        return 'Outro';
    }
  }

  IconData get icon {
    switch (this) {
      case PetEventType.vaccine:
        return Icons.vaccines_outlined;
      case PetEventType.bath:
        return Icons.shower_outlined;
      case PetEventType.deworming:
        return Icons.science_outlined;
      case PetEventType.grooming:
        return Icons.content_cut_outlined;
      case PetEventType.feeding:
        return Icons.pets_outlined;
      case PetEventType.vetVisit:
        return Icons.medical_services_outlined;
      case PetEventType.other:
        return Icons.event_note_outlined;
    }
  }

  static PetEventType fromName(String name) {
    return PetEventType.values.firstWhere((type) => type.name == name,
        orElse: () => PetEventType.other);
  }
}
