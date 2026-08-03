import 'package:flutter/material.dart';
import 'features/onboarding/screens/welcome_screen.dart';
import 'features/onboarding/screens/level_check_screen.dart';
import 'features/assessment/screens/assessment_screen.dart';
import 'features/assessment/screens/assessment_result_screen.dart';
import 'features/coach/screens/coach_screen.dart';
import 'features/session/screens/session_screen.dart';
import 'features/reflection/screens/reflection_screen.dart';
import 'features/closing/screens/closing_screen.dart';

class PoolOSApp extends StatelessWidget {
  const PoolOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pool OS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/level-check': (context) => const LevelCheckScreen(),
        '/assessment': (context) => const AssessmentScreen(),
        '/assessment/result': (context) => const AssessmentResultScreen(),
        '/coach': (context) => const CoachScreen(),
        '/session': (context) => const SessionScreen(),
        '/reflection': (context) => const ReflectionScreen(),
        '/closing': (context) => const ClosingScreen(),
      },
    );
  }
}
