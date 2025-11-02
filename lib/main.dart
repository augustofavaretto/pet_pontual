import 'package:flutter/material.dart';

void main() {
  runApp(const PetPontualApp());
}

class PetPontualApp extends StatelessWidget {
  const PetPontualApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Pontual',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Pontual'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            FlutterLogo(size: 96),
            SizedBox(height: 24),
            Text(
              'Olá! Esta é a estrutura inicial do app Pet Pontual.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
