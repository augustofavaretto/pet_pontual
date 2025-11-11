import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/pet_controller.dart';
import '../models/pet_event.dart';

class _ServiceSection {
  const _ServiceSection({this.title, required this.options});

  final String? title;
  final List<String> options;
}

const Map<PetEventType, List<_ServiceSection>> _serviceCatalog = {
  PetEventType.bath: [
    _ServiceSection(
      title: 'Serviços de banho',
      options: [
        'Banho tradicional',
        'Banho medicamentoso',
        'Banho a seco',
        'Hidratação',
      ],
    ),
  ],
  PetEventType.grooming: [
    _ServiceSection(
      title: 'Serviços de tosa e estética',
      options: [
        'Tosa higiênica',
        'Tosa completa',
        'Tosa na tesoura',
        'Penteado/Acabamento',
        'Corte de unhas',
        'Limpeza de ouvidos',
        'Escovação dental',
      ],
    ),
  ],
  PetEventType.deworming: [
    _ServiceSection(
      title: 'Tratamentos de vermífugo',
      options: [
        'Dose oral',
        'Dose tópica',
        'Dose injetável',
        'Vermífugo para filhotes',
        'Vermífugo reforço',
      ],
    ),
  ],
  PetEventType.feeding: [
    _ServiceSection(
      title: 'Rotina de alimentação',
      options: [
        'Ração seca',
        'Ração úmida',
        'Dieta natural',
        'Suplementação',
        'Troca de ração',
      ],
    ),
  ],
  PetEventType.vetVisit: [
    _ServiceSection(
      title: 'Tipos de consulta',
      options: [
        'Check-up',
        'Retorno',
        'Emergência',
        'Especialista',
        'Exames laboratoriais',
      ],
    ),
  ],
  PetEventType.vaccine: [
    _ServiceSection(
      title: 'Cães',
      options: [
        'V8/V10 (Polivalente)',
        'Raiva',
        'Gripe canina (Bordetella)',
        'Giardíase',
        'Leishmaniose',
        'Tosse dos canis (Bronchiguard)',
      ],
    ),
    _ServiceSection(
      title: 'Gatos',
      options: [
        'V4/V5 (Polivalente)',
        'Raiva',
        'FeLV (Leucemia felina)',
        'Rinotraqueíte',
        'Panleucopenia',
      ],
    ),
    _ServiceSection(
      title: 'Roedores',
      options: [
        'Raiva',
        'Enterite bacteriana',
        'Peste de roedores',
      ],
    ),
    _ServiceSection(
      title: 'Pássaros',
      options: [
        'Newcastle',
        'Bouba aviária',
        'Bronquite infecciosa',
        'Gumboro',
      ],
    ),
  ],
  PetEventType.other: [
    _ServiceSection(
      title: 'Serviços gerais',
      options: [
        'Adestramento',
        'Passeio',
        'Hospedagem',
        'Transporte',
        'Outro',
      ],
    ),
  ],
};

class AddPetEventPage extends StatefulWidget {
  static const routeName = '/novo_evento';

  const AddPetEventPage({
    super.key,
    required this.petId,
    this.eventId,
  });

  final String petId;
  final String? eventId;

  bool get isEditing => eventId != null;

  @override
  State<AddPetEventPage> createState() => _AddPetEventPageState();
}

class _AddPetEventPageState extends State<AddPetEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();

  late DateTime _eventDate = DateTime.now();
  PetEventType? _selectedType;

  bool _loadedInitialValues = false;
  final Set<String> _selectedServices = <String>{};

  PetEvent? _existingEvent() {
    if (!widget.isEditing) return null;
    final controller = context.read<PetController>();
    try {
      return controller
          .eventsFor(widget.petId)
          .firstWhere((event) => event.id == widget.eventId);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadedInitialValues && widget.isEditing) {
      final event = _existingEvent();
      if (event != null) {
        _selectedType = event.type;
        _eventDate = event.date;
        _noteController.text = event.note ?? '';
        _selectedServices
          ..clear()
          ..addAll(event.services);
      }
      _loadedInitialValues = true;
    }

    final petName = context.select<PetController, String?>(
      (controller) => controller.findById(widget.petId)?.name,
    );

    if (petName == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pet não encontrado'),
        ),
        body: const Center(
          child: Text('Não foi possível localizar o pet selecionado.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.isEditing ? 'Editar evento' : 'Novo evento para $petName'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ignore: deprecated_member_use
                DropdownButtonFormField<PetEventType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de evento',
                  ),
                  items: PetEventType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                      _selectedServices.clear();
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Selecione um tipo' : null,
                ),
                const SizedBox(height: 16),
                _DatePickerTile(
                  label: 'Data do evento',
                  dateTime: _eventDate,
                  onTap: _pickEventDate,
                ),
                const SizedBox(height: 16),
                if (_selectedType != null) ...[
                  _ServicesChecklist(
                    sections: _serviceCatalog[_selectedType!] ??
                        const <_ServiceSection>[],
                    selected: _selectedServices,
                    onChanged: _toggleService,
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Observações adicionais',
                    hintText: 'Digite observações extras, se necessário',
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _submit,
                  child: Text(
                      widget.isEditing ? 'Salvar alterações' : 'Salvar evento'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickEventDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Data do evento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (selected != null) {
      setState(() {
        _eventDate = selected;
      });
    }
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final note = _noteController.text.trim();
    final existingReminder =
        widget.isEditing ? _existingEvent()?.reminderDate : null;

    final controller = context.read<PetController>();

    if (widget.isEditing && widget.eventId != null) {
      final updatedEvent = PetEvent(
        id: widget.eventId!,
        type: _selectedType!,
        date: _eventDate,
        note: note.isEmpty ? null : note,
        reminderDate: existingReminder,
        services: _selectedServices.toList(),
      );

      await controller.updateEvent(
        petId: widget.petId,
        updatedEvent: updatedEvent,
      );
    } else {
      final event = PetEvent(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: _selectedType!,
        date: _eventDate,
        note: note.isEmpty ? null : note,
        reminderDate: null,
        services: _selectedServices.toList(),
      );

      await controller.addEvent(
        petId: widget.petId,
        event: event,
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _toggleService(String service, bool enabled) {
    setState(() {
      if (enabled) {
        _selectedServices.add(service);
      } else {
        _selectedServices.remove(service);
      }
    });
  }
}

class _ServicesChecklist extends StatelessWidget {
  const _ServicesChecklist({
    required this.sections,
    required this.selected,
    required this.onChanged,
  });

  final List<_ServiceSection> sections;
  final Set<String> selected;
  final void Function(String service, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Serviços realizados',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...sections.map((section) {
          return _ServiceSectionList(
            section: section,
            selected: selected,
            onChanged: onChanged,
          );
        }),
      ],
    );
  }
}

class _ServiceSectionList extends StatelessWidget {
  const _ServiceSectionList({
    required this.section,
    required this.selected,
    required this.onChanged,
  });

  final _ServiceSection section;
  final Set<String> selected;
  final void Function(String service, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.title != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              section.title!,
              style: theme.textTheme.titleSmall!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
        ...section.options.map(
          (service) => CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: selected.contains(service),
            onChanged: (value) => onChanged(service, value ?? false),
            title: Text(service),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({
    required this.label,
    required this.dateTime,
    required this.onTap,
  });

  final String label;
  final DateTime dateTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatted = _formatDate(dateTime);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(formatted),
      onTap: onTap,
      trailing: const Icon(Icons.calendar_today_outlined),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}

class _TimePickerTile extends StatelessWidget {
  const _TimePickerTile({
    required this.time,
    required this.onTap,
  });

  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatted = time.format(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Horário do lembrete'),
      subtitle: Text(formatted),
      onTap: onTap,
      trailing: const Icon(Icons.schedule_outlined),
    );
  }
}
