enum PetEventType {
  vaccine,
  bath,
  deworming,
  grooming,
  feeding,
  vetVisit,
  other,
}

class PetEvent {
  const PetEvent({
    required this.type,
    required this.date,
    this.note,
    this.reminderDate,
  });

  final PetEventType type;
  final DateTime date;
  final String? note;
  final DateTime? reminderDate;
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
}
