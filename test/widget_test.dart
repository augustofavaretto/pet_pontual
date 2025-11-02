import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pet_pontual/main.dart';

void main() {
  testWidgets('HomePage exibe texto esperado', (WidgetTester tester) async {
    await tester.pumpWidget(const PetPontualApp());

    expect(find.text('Pet Pontual'), findsOneWidget);
    expect(
      find.text('Olá! Esta é a estrutura inicial do app Pet Pontual.'),
      findsOneWidget,
    );
    expect(find.byType(FlutterLogo), findsOneWidget);
  });
}
