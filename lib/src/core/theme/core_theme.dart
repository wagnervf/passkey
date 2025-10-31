import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keezy/src/core/theme/color_schemes.g.dart';
//import 'package:keezy/src/core/theme/theme.dart';

// final pageTransitionsTheme = const PageTransitionsTheme(
//   builders: <TargetPlatform, PageTransitionsBuilder>{
//     TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
//     TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
//     TargetPlatform.linux: NoAnimationPageTransitionsBuilder(),
//     TargetPlatform.macOS: NoAnimationPageTransitionsBuilder(),
//     TargetPlatform.windows: NoAnimationPageTransitionsBuilder(),
//   },
// );

ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      primaryColor: lightColorScheme.primary,
      cardColor: lightColorScheme.primaryContainer,
      listTileTheme: ListTileThemeData(iconColor: lightColorScheme.primary),
      brightness: Brightness.light,
      primaryColorLight: lightColorScheme.primary,
      primaryColorDark: lightColorScheme.primary,
      scaffoldBackgroundColor: lightColorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: lightColorScheme.surface,
        titleTextStyle: const TextStyle(fontSize: 18, color: Colors.black),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: lightColorScheme.surface,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightColorScheme.primary,
        foregroundColor: lightColorScheme.surface,
      ),
      iconTheme: IconThemeData(color: lightColorScheme.primary),
      dividerColor: Colors.grey[300],
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFFFFFFF),
        selectedItemColor: lightColorScheme.primary,
        unselectedItemColor: Colors.grey,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: lightColorScheme.primary,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            backgroundColor: lightColorScheme.primary,
            foregroundColor: lightColorScheme.surface),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: lightColorScheme.primary,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: lightColorScheme.surface,
          textStyle: TextStyle(color: lightColorScheme.surface),
          // side: BorderSide(
          //   color: lightColorScheme.primary,
          //   width: 1,
          // ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
      ),
        textSelectionTheme: TextSelectionThemeData(
        selectionColor: lightColorScheme.tertiary,
        cursorColor: lightColorScheme.secondary,
        //  selectionHandleColor: darkColorScheme.primary,
      ),
      iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
              iconColor: WidgetStatePropertyAll(lightColorScheme.primary),
              foregroundColor:
                  WidgetStatePropertyAll(lightColorScheme.primary))),
      cardTheme: CardThemeData(color: lightColorScheme.surface),
      inputDecorationTheme: InputDecorationTheme(
          fillColor: lightColorScheme.surface,
          //   fillColor: const Color.fromARGB(255, 235, 253, 252),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(7.0)),
            borderSide: BorderSide(
              color: lightColorScheme.primary,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(7.0)),
            borderSide: BorderSide(
              color: lightColorScheme.primary,
              width: 1,
            ),
          ),
          filled: true,
          hintStyle: TextStyle(
            color: lightColorScheme.primary,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          )),
      segmentedButtonTheme: _segmentedButtonTheme(),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: lightColorScheme.primary,
        ),
        displayMedium: TextStyle(
          color: lightColorScheme.primary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: lightColorScheme.primary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        labelMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: lightColorScheme.primary,
        ),
        labelSmall: TextStyle(
          color: lightColorScheme.primary,
          fontSize: 12,
        ),
        titleLarge: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        titleMedium: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        titleSmall: const TextStyle(fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: lightColorScheme.surface, fontSize: 12),
        bodySmall: TextStyle(fontSize: 12, color: lightColorScheme.outline),
        bodyMedium: const TextStyle(
          fontSize: 16,
          //  color: Colors.white,
        ),
        bodyLarge: const TextStyle(
          fontSize: 20,
          //color: Colors.white,
        ),
      ),
    );

ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,

      // fontFamily: 'Roboto',
      // pageTransitionsTheme: pageTransitionsTheme,
      brightness: Brightness.dark,
      primaryColor: darkColorScheme.primary,
      primaryColorLight: lightColorScheme.primary,
      primaryColorDark: const Color(0xFF0B141A),
      scaffoldBackgroundColor: const Color(0xFF121B22),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF25D366),
        foregroundColor: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      // listTileTheme: ListTileThemeData(tileColor: Colors.amber),
      cardTheme: CardThemeData(color: darkColorScheme.onPrimaryContainer),

      dividerColor: Colors.grey[700],
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1F2C34),
        selectedItemColor: Color(0xFF25D366),
        unselectedItemColor: Colors.grey,
      ),
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              foregroundColor:
                  WidgetStatePropertyAll(darkColorScheme.secondary))),
      // primaryColor: darkColorScheme.onPrimary,
      appBarTheme: AppBarTheme(
        // centerTitle: true,
        //  color: darkColorScheme.onPrimary,
        actionsIconTheme: IconThemeData(
          color: darkColorScheme.secondary,
        ),
        iconTheme: IconThemeData(color: darkColorScheme.secondary),
        elevation: 0,
        titleTextStyle:
            TextStyle(fontSize: 18, color: darkColorScheme.secondary),
        foregroundColor: darkColorScheme.secondary,
        //backgroundColor: darkColorScheme.secondary,

        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: darkColorScheme.onPrimary,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      segmentedButtonTheme: _segmentedButtonTheme(),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: darkColorScheme.tertiary,
        cursorColor: darkColorScheme.secondary,
        //  selectionHandleColor: darkColorScheme.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
          fillColor: darkColorScheme.surface,
          //   fillColor: const Color.fromARGB(255, 235, 253, 252),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(7.0)),
            borderSide: BorderSide(
              color: darkColorScheme.primary,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(7.0)),
            borderSide: BorderSide(
              color: darkColorScheme.primary,
              width: 1,
            ),
          ),
          filled: true,
          hintStyle: TextStyle(
            color: lightColorScheme.primary,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          )),
      iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
              iconColor: WidgetStatePropertyAll(
                Colors.white,
              ),
              foregroundColor: WidgetStatePropertyAll(Colors.white))),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: darkColorScheme.primary,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            backgroundColor: darkColorScheme.primary,
            foregroundColor: Colors.white),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Colors.white,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          foregroundColor: Colors.white,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: darkColorScheme.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(color: Colors.white),
          side: BorderSide(
            color: darkColorScheme.primary,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        labelMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          // color: lightColorScheme.primary,
        ),
        labelSmall: TextStyle(
          color: darkColorScheme.secondary,
          fontSize: 12,
          //   color: lightColorScheme.primary,
        ),
        titleLarge: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.bold,
          // fontSize: 18,
          color: lightColorScheme.onPrimary,
        ),
        titleSmall: TextStyle(
            color: darkColorScheme.secondary, fontWeight: FontWeight.bold),
      ),
    );

// Um gerenciador de estado por Tema
SegmentedButtonThemeData _segmentedButtonTheme() {
  return SegmentedButtonThemeData(style: ButtonStyle(
    textStyle: WidgetStateProperty.resolveWith<TextStyle>(
      (states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(fontSize: 9.0);
        }
        return const TextStyle(fontSize: 12.0);
      },
    ),
  ));
}
