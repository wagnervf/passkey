import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keezy/src/core/components/item_card_with_icon.dart';

void main() {
  testWidgets('item disabled não executa a ação', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemCardWithIcon(
            text: 'Exportar Registros',
            subtTitle: 'Adicione um registro para habilitar a exportação.',
            icon: Icons.share,
            enabled: false,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Exportar Registros'));
    expect(tapped, isFalse);
  });
}
