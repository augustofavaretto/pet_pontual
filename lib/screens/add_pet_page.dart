import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../controllers/pet_controller.dart';

class AddPetPage extends StatefulWidget {
  static const routeName = '/novo_pet';

  const AddPetPage({super.key, this.petId});

  final String? petId;

  bool get isEditing => petId != null;

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
  String? _existingAvatarPath;
  String? _existingAvatarAsset;
  bool _didLoadInitialValues = false;
  String? _pendingDeletionPath;

  static const List<String> _speciesSuggestions = [
    'Cachorro',
    'Gato',
    'Pássaro',
    'Roedor',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadInitialValues || !widget.isEditing) return;

    final pet = context.read<PetController>().findById(widget.petId!);
    if (pet != null) {
      _nameController.text = pet.name;
      _breedController.text = pet.breed ?? '';
      _selectedType = pet.type;
      _birthDate = pet.birthDate;
      _existingAvatarPath = pet.avatarPath;
      _existingAvatarAsset = pet.avatarAsset;
      _pendingDeletionPath = null;
    }

    _didLoadInitialValues = true;
  }

  @override
  Widget build(BuildContext context) {
    final typeOptions = List<String>.from(_speciesSuggestions);
    if (_selectedType != null && !typeOptions.contains(_selectedType)) {
      typeOptions.insert(0, _selectedType!);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar pet' : 'Cadastrar novo pet'),
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
                  existingPath: _photo == null ? _existingAvatarPath : null,
                  existingAsset: _photo == null ? _existingAvatarAsset : null,
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
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    hintText: 'Selecione o tipo do pet',
                  ),
                  items: typeOptions
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
                  child:
                      Text(widget.isEditing ? 'Salvar alterações' : 'Salvar'),
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
      setState(() {
        _photo = image;
        _pendingDeletionPath ??= _existingAvatarPath;
        _existingAvatarPath = null;
        _existingAvatarAsset = null;
      });
    }
  }

  Future<void> _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final controller = context.read<PetController>();
    final name = _nameController.text.trim();
    final type = _selectedType!.trim();
    final breedText = _breedController.text.trim();
    final breed = breedText.isEmpty ? null : breedText;
    String? avatarPath = _existingAvatarPath;
    if (_photo != null) {
      avatarPath = await _persistImage(_photo!);
      await _deleteLocalFile(_pendingDeletionPath);
      _pendingDeletionPath = null;
    }
    final avatarAsset = _photo != null ? null : _existingAvatarAsset;

    if (widget.isEditing) {
      await controller.updatePet(
        petId: widget.petId!,
        name: name,
        type: type,
        breed: breed,
        birthDate: _birthDate,
        avatarPath: avatarPath,
        avatarAsset: avatarAsset,
      );
    } else {
      await controller.addPet(
        name: name,
        type: type,
        breed: breed,
        avatarPath: avatarPath,
        birthDate: _birthDate,
        avatarAsset: avatarAsset,
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<String> _persistImage(XFile file) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(documentsDir.path, 'pet_photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final fileExtension = p.extension(file.path);
    final fileName =
        'pet_${DateTime.now().microsecondsSinceEpoch}$fileExtension';
    final newFullPath = p.join(photosDir.path, fileName);

    await File(file.path).copy(newFullPath);
    return p.join('pet_photos', fileName);
  }

  Future<void> _deleteLocalFile(String? path) async {
    if (path == null || path.startsWith('assets/')) return;
    final documentsDir = await getApplicationDocumentsDirectory();
    final absolutePath = path.startsWith(documentsDir.path)
        ? path
        : p.join(documentsDir.path, path);
    final file = File(absolutePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

class _PhotoPickerPreview extends StatelessWidget {
  const _PhotoPickerPreview({
    required this.photo,
    required this.onTap,
    this.existingPath,
    this.existingAsset,
  });

  final XFile? photo;
  final VoidCallback onTap;
  final String? existingPath;
  final String? existingAsset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageProvider = _resolveImageProvider();

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
          child: imageProvider != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image(
                    image: imageProvider,
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

  ImageProvider<Object>? _resolveImageProvider() {
    if (photo != null) {
      return FileImage(File(photo!.path));
    }
    if (existingPath != null && existingPath!.isNotEmpty) {
      final file = File(existingPath!);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    if (existingAsset != null && existingAsset!.isNotEmpty) {
      return AssetImage(existingAsset!);
    }
    return null;
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
