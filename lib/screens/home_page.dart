import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/pet_controller.dart';
import '../models/pet.dart';
import '../navigation/app_router.dart';
import 'add_pet_page.dart';
import 'pet_detail_page.dart';

class HomePage extends StatelessWidget {
  static const routeName = '/';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final pets = context.watch<PetController>().pets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seus Pets'),
      ),
      body: pets.isEmpty ? const _EmptyPetsView() : _PetsListView(pets: pets),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openPetForm(context),
        tooltip: 'Adicionar pet',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openPetForm(BuildContext context) {
    Navigator.of(context).pushNamed<void>(AddPetPage.routeName);
  }
}

class _EmptyPetsView extends StatelessWidget {
  const _EmptyPetsView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Você ainda não cadastrou nenhum pet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Use o botão “+” para adicionar o primeiro pet e começar a acompanhar vacinas e banhos.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PetsListView extends StatelessWidget {
  const _PetsListView({required this.pets});

  final List<Pet> pets;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemBuilder: (context, index) {
        final pet = pets[index];

        return Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: _PetAvatar(pet: pet),
            title: Text(pet.name),
            subtitle: Text(pet.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _editPet(context, pet),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Theme.of(context).colorScheme.error,
                  tooltip: 'Excluir',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _confirmDelete(context, pet),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () => _openPetDetails(context, pet),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: pets.length,
    );
  }

  void _openPetDetails(BuildContext context, Pet pet) {
    Navigator.of(context).pushNamed<void>(
      PetDetailPage.routeName,
      arguments: PetDetailPageArgs(petId: pet.id),
    );
  }

  void _editPet(BuildContext context, Pet pet) {
    Navigator.of(context).pushNamed<void>(
      AddPetPage.routeName,
      arguments: AddPetPageArgs(petId: pet.id),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Pet pet) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir pet'),
        content: Text('Tem certeza que deseja excluir ${pet.name}?'),
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
      context.read<PetController>().removePet(pet.id);
    }
  }
}

class _PetAvatar extends StatelessWidget {
  const _PetAvatar({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final backgroundImage = _resolveAvatarImage();
    final initials = pet.name.isEmpty ? '?' : pet.name[0].toUpperCase();

    return CircleAvatar(
      backgroundImage: backgroundImage,
      child: backgroundImage == null
          ? Text(
              initials,
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
          : null,
    );
  }

  ImageProvider<Object>? _resolveAvatarImage() {
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
}
