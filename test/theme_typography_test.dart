import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keezy/src/core/theme/core_theme.dart';

double contrastRatio(Color foreground, Color background) {
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  final lighter = a > b ? a : b;
  final darker = a > b ? b : a;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  test('títulos e texto auxiliar mantêm hierarquia nos dois temas', () {
    for (final theme in [lightTheme, darkTheme]) {
      final title = theme.textTheme.headlineSmall!;
      final body = theme.textTheme.bodyMedium!;
      final supporting = theme.textTheme.bodySmall!;

      expect(title.color, theme.colorScheme.onSurface);
      expect(title.fontSize, greaterThan(body.fontSize!));
      expect(supporting.fontSize, greaterThanOrEqualTo(14));
      expect(supporting.color, theme.colorScheme.onSurfaceVariant);
    }
  });

  test('cores de texto principais têm contraste mínimo nos dois temas', () {
    for (final theme in [lightTheme, darkTheme]) {
      final colors = theme.colorScheme;
      expect(
        contrastRatio(colors.onSurface, colors.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrastRatio(colors.onSurfaceVariant, colors.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrastRatio(colors.onError, colors.error),
        greaterThanOrEqualTo(4.5),
      );
    }
    expect(
      contrastRatio(
        lightTheme.colorScheme.onPrimary,
        lightTheme.colorScheme.primary,
      ),
      greaterThanOrEqualTo(4.5),
    );
    final darkInputBorder =
        darkTheme.inputDecorationTheme.enabledBorder as OutlineInputBorder;
    expect(
      contrastRatio(
        darkInputBorder.borderSide.color,
        darkTheme.colorScheme.surface,
      ),
      greaterThanOrEqualTo(3),
    );
  });
}
