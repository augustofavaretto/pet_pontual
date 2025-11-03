import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pet_pontual/main.dart';
import 'package:pet_pontual/controllers/pet_controller.dart';
import 'package:pet_pontual/screens/home_page.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('HomePage exibe lista de pets cadastrados',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PetPontualApp());

    expect(find.text('Seus Pets'), findsOneWidget);
    expect(find.text('Luna'), findsOneWidget);
    expect(find.text('Thor'), findsOneWidget);
    expect(find.text('Mel'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(3));
  });

  testWidgets('HomePage mostra estado vazio quando não há pets',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => PetController(loadSampleData: false),
        child: const MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    expect(find.text('Você ainda não cadastrou nenhum pet.'), findsOneWidget);
    expect(find.textContaining('Use o botão “+”'), findsOneWidget);
  });
}
