import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/pet_controller.dart';
import '../models/pet.dart';
import '../models/pet_event.dart';
import '../navigation/app_router.dart';
import 'add_pet_event_page.dart';

class PetDetailPage extends StatefulWidget {
  static const routeName = '/detalhe_pet';

  const PetDetailPage({super.key, required this.petId});

  final String petId;

  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage> {
  PetEventType? _selectedType;
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PetController>();
    final pet = controller.findById(widget.petId);

    if (pet == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pet não encontrado'),
        ),
        body: const Center(
          child: Text('Não foi possível localizar o pet selecionado.'),
        ),
      );
    }

    final sortedEvents = List<PetEvent>.from(pet.events)..sort(_sortEvents);
    final events = _applyFilters(sortedEvents);

    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEventPage(context, pet),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, pet),
            const SizedBox(height: 24),
            _buildFilters(context),
            const SizedBox(height: 16),
            Expanded(
              child: _buildEventList(context, events, sortedEvents.isNotEmpty),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Pet pet) {
    final avatarImage = _resolveAvatarImage(pet);
    final theme = Theme.of(context);
    final hasBirthDate = pet.birthDate != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 36,
          backgroundImage: avatarImage,
          child: avatarImage == null
              ? Text(
                  pet.name.isEmpty ? '?' : pet.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pet.name,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                pet.description,
                style: theme.textTheme.bodyMedium,
              ),
              if (hasBirthDate) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.cake_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Nascimento: ${_formatDate(pet.birthDate!)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Idade: ${_formatAge(pet.birthDate!)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context) {
    final theme = Theme.of(context);
    final allTypesOption = DropdownMenuItem<PetEventType?>(
      value: null,
      child: Text(
        'Todas as categorias',
        style: theme.textTheme.bodyMedium,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;
        final fieldWidth =
            isCompact ? constraints.maxWidth : (constraints.maxWidth - 12) / 2;

        final filterFields = [
          SizedBox(
            width: fieldWidth,
            child:
                // ignore: deprecated_member_use
                DropdownButtonFormField<PetEventType?>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo de evento',
                border: OutlineInputBorder(),
              ),
              items: [
                allTypesOption,
                ...PetEventType.values.map(
                  (type) => DropdownMenuItem<PetEventType?>(
                    value: type,
                    child: Text(type.label),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _selectedType = value),
            ),
          ),
          SizedBox(
            width: fieldWidth,
            child: OutlinedButton.icon(
              onPressed: _pickDateRange,
              icon: const Icon(Icons.date_range),
              label: Text(
                _selectedDateRange == null
                    ? 'Intervalo de datas'
                    : '${_formatDate(_selectedDateRange!.start)} · ${_formatDate(_selectedDateRange!.end)}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: filterFields,
            ),
            if (_hasActiveFilters)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Text(
                      'Filtros aplicados',
                      style: theme.textTheme.bodySmall,
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.close),
                      label: const Text('Limpar'),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEventList(
    BuildContext context,
    List<PetEvent> events,
    bool hadEventsBeforeFilter,
  ) {
    if (events.isEmpty) {
      final message = hadEventsBeforeFilter
          ? 'Nenhum evento encontrado com os filtros atuais.'
          : 'Nenhum evento registrado.';

      return Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            onTap: () => _openEditEvent(context, event),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                event.type.icon,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(event.type.label),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatDate(event.date)),
                if (event.services.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: event.services
                        .map(
                          (service) => Chip(
                            label: Text(service),
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (event.note != null && event.note!.trim().isNotEmpty)
                  Text(
                    event.note!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (event.reminderDate != null)
                  Text(
                    'Lembrete: ${_formatDateTime(event.reminderDate!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar evento',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _openEditEvent(context, event),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Theme.of(context).colorScheme.error,
                  tooltip: 'Excluir evento',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _confirmDeleteEvent(context, event),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<PetEvent> _applyFilters(List<PetEvent> events) {
    return events.where((event) {
      final matchesType = _selectedType == null || event.type == _selectedType;
      final matchesDate = _selectedDateRange == null ||
          _isWithinRange(event.date, _selectedDateRange!);
      return matchesType && matchesDate;
    }).toList();
  }

  bool get _hasActiveFilters =>
      _selectedType != null || _selectedDateRange != null;

  bool _isWithinRange(DateTime date, DateTimeRange range) {
    final from = DateTime(range.start.year, range.start.month, range.start.day);
    final to =
        DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);
    return !date.isBefore(from) && !date.isAfter(to);
  }

  void _openAddEventPage(BuildContext context, Pet pet) {
    Navigator.of(context).pushNamed<void>(
      AddPetEventPage.routeName,
      arguments: AddPetEventPageArgs(petId: pet.id),
    );
  }

  void _openEditEvent(BuildContext context, PetEvent event) {
    Navigator.of(context).pushNamed<void>(
      AddPetEventPage.routeName,
      arguments: AddPetEventPageArgs(
        petId: widget.petId,
        eventId: event.id,
      ),
    );
  }

  Future<void> _confirmDeleteEvent(BuildContext context, PetEvent event) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir evento'),
        content: Text(
          'Deseja excluir o evento "${event.type.label}" de ${_formatDate(event.date)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      if (!context.mounted) return;
      context
          .read<PetController>()
          .removeEvent(petId: widget.petId, eventId: event.id);
    }
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      helpText: 'Filtrar por intervalo',
      cancelText: 'Cancelar',
      confirmText: 'Aplicar',
    );

    if (!mounted) return;

    if (range != null) {
      setState(() => _selectedDateRange = range);
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedDateRange = null;
    });
  }

  ImageProvider<Object>? _resolveAvatarImage(Pet pet) {
    if (pet.avatarPath != null && pet.avatarPath!.isNotEmpty) {
      final file = File(pet.avatarPath!);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }

    if (pet.avatarAsset != null && pet.avatarAsset!.isNotEmpty) {
      return AssetImage(pet.avatarAsset!);
    }

    return null;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  String _formatDateTime(DateTime dateTime) {
    final date = _formatDate(dateTime);
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$date às $hour:$minute';
  }

  String _formatAge(DateTime birthDate) {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (days < 0) {
      months -= 1;
      final previousMonth = DateTime(now.year, now.month, 0);
      days += previousMonth.day;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }

    final yearsLabel =
        years > 0 ? '$years ${years == 1 ? 'ano' : 'anos'}' : null;
    final monthsLabel =
        months > 0 ? '$months ${months == 1 ? 'mês' : 'meses'}' : null;

    if (yearsLabel != null && monthsLabel != null) {
      return '$yearsLabel e $monthsLabel';
    }
    if (yearsLabel != null) {
      return yearsLabel;
    }
    if (monthsLabel != null) {
      return monthsLabel;
    }
    return 'menor de um mês';
  }

  int _sortEvents(PetEvent a, PetEvent b) {
    return b.date.compareTo(a.date);
  }
}
