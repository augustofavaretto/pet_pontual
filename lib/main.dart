import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/pet_controller.dart';
import 'navigation/app_router.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const PetPontualApp());
}

class PetPontualApp extends StatelessWidget {
  const PetPontualApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PetController()),
      ],
      child: MaterialApp(
        title: 'Pet Pontual',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: const Color(0xFF0EA5A7)),
          useMaterial3: true,
        ),
        initialRoute: HomePage.routeName,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
