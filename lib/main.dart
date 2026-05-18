import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notifications_service.dart';
import 'shared/providers/database_providers.dart';

/// Point d'entrée de l'application Heza Money
/// 100% offline — aucune connexion réseau requise
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise les données de localisation françaises (formatage des dates)
  await initializeDateFormatting('fr_FR', null);

  // Initialise le service de notifications (rappel mensuel du 1er)
  await NotificationsService().init();

  runApp(
    // ProviderScope — racine de Riverpod, gère tous les providers
    const ProviderScope(
      child: HezaMoneyApp(),
    ),
  );
}

/// Widget racine de l'application
class HezaMoneyApp extends ConsumerWidget {
  const HezaMoneyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Écoute le mode thème depuis le profil utilisateur
    final themeMode = ref.watch(themeModeProvider);

    // Convertit l'entier en ThemeMode Flutter
    final flutterThemeMode = switch (themeMode) {
      1 => ThemeMode.dark,
      2 => ThemeMode.system,
      _ => ThemeMode.light,
    };

    return MaterialApp.router(
      // ─── Métadonnées de l'app ───
      title: 'Heza Money',
      debugShowCheckedModeBanner: false,

      // ─── Thèmes ───
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: flutterThemeMode,

      // ─── Localisation ───
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ─── Navigation (go_router) ───
      routerConfig: AppRouter.router,
    );
  }
}
