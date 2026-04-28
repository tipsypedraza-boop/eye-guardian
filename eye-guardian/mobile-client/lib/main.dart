import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/state_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EyeGuardianApp());
}

class EyeGuardianApp extends StatelessWidget {
  const EyeGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '护眼精灵',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        colorScheme: const ColorScheme.dark(primary: Color(0xFF7DF9FF)),
      ),
      home: const HomeScreen(),
    );
  }
}
