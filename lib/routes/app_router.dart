import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/diagnosis_screen.dart';
import '../screens/doctors_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/diagnosis_questionnaire_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/diagnosis',
        name: 'diagnosis',
        builder: (context, state) => const DiagnosisScreen(),
      ),
      GoRoute(
        path: '/diagnosis/questionnaire',
        name: 'diagnosis_questionnaire',
        builder: (context, state) => const DiagnosisQuestionnaireScreen(),
      ),
      GoRoute(
        path: '/doctors',
        name: 'doctors',
        builder: (context, state) => const DoctorsScreen(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}
