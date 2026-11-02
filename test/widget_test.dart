import 'package:aula7_calendario/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a tela abre com o botão e sem compromissos carregados', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TelaCompromissos()));

    expect(find.text('Consultar compromissos'), findsOneWidget);
    expect(
      find.text('Pressione o botão para consultar os compromissos.'),
      findsOneWidget,
    );
    expect(find.text('Folha em branco'), findsOneWidget);
  });
}
