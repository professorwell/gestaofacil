/// lib/main.dart
/// GestãoFacil
/// (c) 2025 Welington Matheus Almeida de Souza
/// Criado para registro de vendas à vista e fiado por comando de voz.
import 'package:flutter/material.dart';
import 'pages/dashboard_page.dart';

// Cor ciano principal usada em todo o app
const Color kPrimaryCiano = Color(0xFF3EB9A6);

/// Controla o modo de tema (claro/escuro)
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'GestãoFacil',
          debugShowCheckedModeBanner: false,
          themeMode: mode,

          // Tema claro
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.light(
              primary: const Color.fromARGB(255, 69, 151, 71),
              secondary: kPrimaryCiano,
            ),
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            appBarTheme: const AppBarTheme(
              backgroundColor: kPrimaryCiano,
              foregroundColor: Colors.white,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),

          // Tema escuro
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.dark(
              primary: Colors.green.shade400,
              secondary: kPrimaryCiano,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
            ),
            cardColor: const Color(0xFF1E1E1E),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade400,
                foregroundColor: Colors.white,
              ),
            ),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.white70),
            ),
          ),

          home: const DashboardPage(),
        );
      },
    );
  }
}
