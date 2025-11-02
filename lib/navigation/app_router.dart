import 'package:flutter/material.dart';

import '../screens/add_pet_event_page.dart';
import '../screens/add_pet_page.dart';
import '../screens/home_page.dart';
import '../screens/pet_detail_page.dart';

class PetDetailPageArgs {
  const PetDetailPageArgs({required this.petId});

  final String petId;
}

class AddPetEventPageArgs {
  const AddPetEventPageArgs({required this.petId});

  final String petId;
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case HomePage.routeName:
      case '/':
        return MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
        );
      case AddPetPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => const AddPetPage(),
          fullscreenDialog: true,
        );
      case PetDetailPage.routeName:
        final args = settings.arguments as PetDetailPageArgs;
        return MaterialPageRoute<void>(
          builder: (_) => PetDetailPage(petId: args.petId),
        );
      case AddPetEventPage.routeName:
        final args = settings.arguments as AddPetEventPageArgs;
        return MaterialPageRoute<void>(
          builder: (_) => AddPetEventPage(petId: args.petId),
          fullscreenDialog: true,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const _UnknownRoutePage(),
        );
    }
  }
}

class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página não encontrada'),
      ),
      body: const Center(
        child: Text('A rota solicitada não existe.'),
      ),
    );
  }
}
