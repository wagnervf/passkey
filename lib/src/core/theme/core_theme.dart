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
            color: lightColorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          )),
      segmentedButtonTheme: _segmentedButtonTheme(),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: lightColorScheme.primary),
        displayMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: lightColorScheme.primary),
        displaySmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: lightColorScheme.primary),
        labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: lightColorScheme.secondary),
        labelSmall: TextStyle(fontSize: 12, color: lightColorScheme.secondary),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: lightColorScheme.onSurface),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: lightColorScheme.onSurface),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: lightColorScheme.onSurface),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: lightColorScheme.onSurface),
        bodySmall: TextStyle(fontSize: 14, color: lightColorScheme.onSurfaceVariant),
        bodyMedium: TextStyle(fontSize: 16, color: lightColorScheme.onSurface),
        bodyLarge: TextStyle(fontSize: 18, color: lightColorScheme.onSurface),
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
              color: darkColorScheme.secondary,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(7.0)),
            borderSide: BorderSide(
              color: darkColorScheme.outline,
              width: 1,
            ),
          ),
          filled: true,
          hintStyle: TextStyle(
            color: darkColorScheme.onSurfaceVariant,
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
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          side: BorderSide(
            color: lightColorScheme.primary,
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
          textStyle: const TextStyle(fontWeight: FontWeight.bold),

          backgroundColor: darkColorScheme.primary,
          foregroundColor: Colors.white,
      //   textStyle: const TextStyle(color: Colors.white),
          side: BorderSide(
            color: lightColorScheme.primary,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        displayMedium: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        displaySmall: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        labelMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        labelSmall: TextStyle(fontSize: 12, color: darkColorScheme.secondary),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkColorScheme.onSurface),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkColorScheme.onSurface),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: darkColorScheme.onSurface),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: darkColorScheme.onSurface),
        bodySmall: TextStyle(fontSize: 14, color: darkColorScheme.onSurfaceVariant),
        bodyMedium: TextStyle(fontSize: 16, color: darkColorScheme.onSurface),
        bodyLarge: TextStyle(fontSize: 18, color: darkColorScheme.onSurface),
      ),
    );

// Um gerenciador de estado por Tema
SegmentedButtonThemeData _segmentedButtonTheme() {
  return SegmentedButtonThemeData(style: ButtonStyle(
    textStyle: WidgetStateProperty.resolveWith<TextStyle>(
      (states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
        }
        return const TextStyle(fontSize: 14);
      },
    ),
  ));
}
