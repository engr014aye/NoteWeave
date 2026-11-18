import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_styles.dart';
import 'core/state/notes_provider.dart';
import 'core/state/theme_provider.dart';
import 'screens/home_navigation_screen.dart';

class CupertinoBounceScrollBehavior extends ScrollBehavior {
  const CupertinoBounceScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  final notesProvider = NotesProvider();
  await notesProvider.loadData();

  runApp(NoteWeaveApp(
    themeProvider: themeProvider,
    notesProvider: notesProvider,
  ));
}

class NoteWeaveApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  final NotesProvider notesProvider;

  const NoteWeaveApp({
    super.key,
    required this.themeProvider,
    required this.notesProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, _) {
        return MaterialApp(
          title: 'NoteWeave',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          scrollBehavior: const CupertinoBounceScrollBehavior(),

          // Light Theme
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.lightBackground,
            primaryColor: AppColors.lightIndigoAccent,
            colorScheme: const ColorScheme.light(
              primary: AppColors.lightIndigoAccent,
              surface: AppColors.lightCard,
              onSurface: AppColors.lightTextPrimary,
            ),
            fontFamily: AppStyles.fontPrimary,
            cardTheme: CardThemeData(
              color: AppColors.lightCard,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.lightBorder, width: 0.8),
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.lightBackground,
              foregroundColor: AppColors.lightTextPrimary,
              elevation: 0,
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),

          // Dark Theme
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.darkBackground,
            primaryColor: AppColors.darkIndigoAccent,
            colorScheme: const ColorScheme.dark(
              primary: AppColors.darkIndigoAccent,
              surface: AppColors.darkCard,
              onSurface: AppColors.darkTextPrimary,
            ),
            fontFamily: AppStyles.fontPrimary,
            cardTheme: CardThemeData(
              color: AppColors.darkCard,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.darkBorder, width: 0.8),
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.darkBackground,
              foregroundColor: AppColors.darkTextPrimary,
              elevation: 0,
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),

          home: HomeNavigationScreen(
            notesProvider: notesProvider,
            themeProvider: themeProvider,
          ),
        );
      },
    );
  }
}
