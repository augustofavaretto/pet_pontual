import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../controllers/pet_controller.dart';

class AddPetPage extends StatefulWidget {
  static const routeName = '/novo_pet';

  const AddPetPage({super.key});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String? _selectedType;
  DateTime? _birthDate;
  XFile? _photo;

  static const List<String> _speciesSuggestions = [
    'Cachorro',
    'Gato',
    'Pássaro',
    'Peixe',
    'Roedor',
    'Réptil',
    'Outro',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar novo pet'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PhotoPickerPreview(
                  photo: _photo,
                  onTap: _pickImage,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    hintText: 'Ex.: Luna',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o nome do pet';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    hintText: 'Selecione o tipo do pet',
                  ),
                  items: _speciesSuggestions
                      .map(
                        (species) => DropdownMenuItem<String>(
                          value: species,
                          child: Text(species),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedType = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecione o tipo do pet';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _breedController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Raça',
                    hintText: 'Ex.: Labrador',
                  ),
                ),
                const SizedBox(height: 16),
                _BirthDateField(
                  birthDate: _birthDate,
                  onTap: _pickBirthDate,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _submitForm,
                  child: const Text('Salvar'),
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

  Future<void> _pickBirthDate() async {
    final today = DateTime.now();
    final initialDate =
        _birthDate ?? DateTime(today.year - 1, today.month, today.day);
    final firstDate = DateTime(today.year - 30);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: today,
      helpText: 'Data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (selectedDate != null) {
      setState(() => _birthDate = selectedDate);
    }
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );

    if (image != null) {
      setState(() => _photo = image);
    }
  }

  void _submitForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    context.read<PetController>().addPet(
          name: _nameController.text.trim(),
          type: _selectedType!.trim(),
          breed: _breedController.text.trim().isEmpty
              ? null
              : _breedController.text.trim(),
          avatarPath: _photo?.path,
          birthDate: _birthDate,
        );

    Navigator.of(context).pop();
  }
}

class _PhotoPickerPreview extends StatelessWidget {
  const _PhotoPickerPreview({
    required this.photo,
    required this.onTap,
  });

  final XFile? photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPhoto = photo != null;

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 3 / 2,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
            ),
          ),
          child: hasPhoto
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(photo!.path),
                    fit: BoxFit.cover,
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Adicionar foto do pet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Toque para escolher uma imagem da galeria',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _BirthDateField extends StatelessWidget {
  const _BirthDateField({
    required this.birthDate,
    required this.onTap,
  });

  final DateTime? birthDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = birthDate != null
        ? '${birthDate!.day.toString().padLeft(2, '0')}/${birthDate!.month.toString().padLeft(2, '0')}/${birthDate!.year}'
        : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Data de nascimento',
          hintText: 'Selecione a data',
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          text ?? 'Selecione a data',
          style: text != null
              ? theme.textTheme.bodyLarge
              : theme.textTheme.bodyLarge?.copyWith(
                  color: theme.hintColor,
                ),
        ),
      ),
    );
  }
}
