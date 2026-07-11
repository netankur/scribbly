import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/scribbly_provider.dart';
import 'screens/main_layout.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScribblyProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScribblyProvider>(
      builder: (context, provider, child) {
        final seedColor = provider.accentColor;
        
        final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(Theme.of(context).textTheme);

        return MaterialApp(
          title: 'Scribbly',
          debugShowCheckedModeBanner: false,
          themeMode: provider.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.light,
            ),
            textTheme: baseTextTheme,
            useMaterial3: true,
            cupertinoOverrideTheme: CupertinoThemeData(
              textTheme: CupertinoTextThemeData(
                textStyle: baseTextTheme.bodyMedium?.copyWith(color: CupertinoColors.label),
                actionTextStyle: baseTextTheme.bodyLarge?.copyWith(color: CupertinoColors.activeBlue),
                navTitleTextStyle: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 17),
                navLargeTitleTextStyle: baseTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 26, letterSpacing: -0.5),
              ),
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.dark,
            ),
            textTheme: baseTextTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
            useMaterial3: true,
            cupertinoOverrideTheme: CupertinoThemeData(
              brightness: Brightness.dark,
              textTheme: CupertinoTextThemeData(
                textStyle: baseTextTheme.bodyMedium?.copyWith(color: CupertinoColors.label),
                actionTextStyle: baseTextTheme.bodyLarge?.copyWith(color: CupertinoColors.activeBlue),
                navTitleTextStyle: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 17),
                navLargeTitleTextStyle: baseTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 26, letterSpacing: -0.5),
              ),
            ),
          ),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(provider.fontSizeScale * 1.05),
              ),
              child: DefaultTextStyle(
                style: baseTextTheme.bodyMedium!.copyWith(
                  decoration: TextDecoration.none, // Removes the yellow underline
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                ),
                child: child!,
              ),
            );
          },
          home: const MainLayout(),
        );
      },
    );
  }
}
