import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/pet_controller.dart';
import '../models/pet_event.dart';

class AddPetEventPage extends StatefulWidget {
  static const routeName = '/novo_evento';

  const AddPetEventPage({
    super.key,
    required this.petId,
  });

  final String petId;

  @override
  State<AddPetEventPage> createState() => _AddPetEventPageState();
}

class _AddPetEventPageState extends State<AddPetEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();

  late DateTime _eventDate = DateTime.now();
  PetEventType? _selectedType;

  bool _reminderEnabled = false;
  DateTime? _reminderDateTime;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Novo evento para $petName'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                  onChanged: (value) => setState(() => _selectedType = value),
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
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição / observações',
                    hintText: 'Opcional',
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                SwitchListTile.adaptive(
                  value: _reminderEnabled,
                  onChanged: _toggleReminder,
                  title: const Text('Adicionar lembrete'),
                  subtitle:
                      const Text('Receber um alerta futuro para este evento'),
                ),
                if (_reminderEnabled) ...[
                  const SizedBox(height: 8),
                  _DatePickerTile(
                    label: 'Data do lembrete',
                    dateTime: _reminderDateTime ?? _eventDate,
                    onTap: _pickReminderDate,
                  ),
                  const SizedBox(height: 12),
                  _TimePickerTile(
                    time: TimeOfDay.fromDateTime(
                        _reminderDateTime ?? DateTime.now()),
                    onTap: _pickReminderTime,
                  ),
                ],
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _submit,
                  child: const Text('Salvar evento'),
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
        if (!_reminderEnabled) return;
        final reminder = _reminderDateTime ?? selected;
        _reminderDateTime = DateTime(
          selected.year,
          selected.month,
          selected.day,
          reminder.hour,
          reminder.minute,
        );
      });
    }
  }

  Future<void> _pickReminderDate() async {
    final initial = _reminderDateTime ?? _eventDate;
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      helpText: 'Data do lembrete',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (selected != null) {
      setState(() {
        final current = _reminderDateTime ?? DateTime.now();
        _reminderDateTime = DateTime(
          selected.year,
          selected.month,
          selected.day,
          current.hour,
          current.minute,
        );
      });
    }
  }

  Future<void> _pickReminderTime() async {
    final current = _reminderDateTime ?? DateTime.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      helpText: 'Horário do lembrete',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (picked != null) {
      setState(() {
        final date = _reminderDateTime ?? DateTime.now();
        _reminderDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _toggleReminder(bool enabled) {
    setState(() {
      _reminderEnabled = enabled;
      if (enabled && _reminderDateTime == null) {
        final now = DateTime.now();
        _reminderDateTime = now.isAfter(_eventDate)
            ? now.add(const Duration(days: 7))
            : DateTime(
                _eventDate.year,
                _eventDate.month,
                _eventDate.day,
                now.hour,
                now.minute,
              );
      }
    });
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final note = _noteController.text.trim();
    final event = PetEvent(
      type: _selectedType!,
      date: _eventDate,
      note: note.isEmpty ? null : note,
      reminderDate: _reminderEnabled ? _reminderDateTime : null,
    );

    context.read<PetController>().addEvent(
          petId: widget.petId,
          event: event,
        );

    Navigator.of(context).pop();
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
