import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../screens/home_screen.dart';
import '../screens/diagnosis_screen.dart';
import '../screens/doctors_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/diagnosis_questionnaire_screen.dart';
import '../screens/color_blind_test_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/doctor_onboarding_screen.dart';
import '../screens/doctor_dashboard_screen.dart';
import '../screens/add_patient_screen.dart';
import '../screens/add_note_screen.dart';
import '../screens/patient_detail_screen.dart';
import '../screens/note_detail_screen.dart';
import '../providers/auth_provider.dart';

class AppRouter {
  static GoRouter createRouter(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: true);
    return GoRouter(
      initialLocation: '/signup', // Set to signup for testing
      refreshListenable: auth,
      redirect: (context, state) {
        final bool loggedIn = auth.isLoggedIn;
        final String path = state.matchedLocation;
        final bool goingToAuth = path == '/login' || path == '/signup';
        final bool goingToOnboarding = path == '/doctor-onboarding';

        if (!loggedIn && !goingToAuth) {
          return '/login';
        }
        if (loggedIn && goingToAuth) {
          return '/';
        }
        // Redirect doctors who need onboarding
        if (loggedIn && auth.needsOnboarding && !goingToOnboarding) {
          return '/doctor-onboarding';
        }
        // Redirect doctors who completed onboarding away from onboarding page
        if (loggedIn && !auth.needsOnboarding && goingToOnboarding) {
          return auth.role == UserRole.doctor ? '/doctor/dashboard' : '/';
        }
        return null;
      },
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
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/color-blind-test',
          name: 'color_blind_test',
          builder: (context, state) => const ColorBlindTestScreen(),
        ),
        GoRoute(
          path: '/doctor-onboarding',
          name: 'doctor_onboarding',
          builder: (context, state) => const DoctorOnboardingScreen(),
        ),
        GoRoute(
          path: '/doctor/dashboard',
          name: 'doctor_dashboard',
          builder: (context, state) => const DoctorDashboardScreen(),
        ),
        GoRoute(
          path: '/doctor/add-patient',
          name: 'add_patient',
          builder: (context, state) => const AddPatientScreen(),
        ),
        GoRoute(
          path: '/doctor/add-note',
          name: 'add_note',
          builder: (context, state) => const AddNoteScreen(),
        ),
        GoRoute(
          path: '/doctor/patient/:patientId',
          name: 'patient_detail',
          builder: (context, state) {
            final patientId = state.pathParameters['patientId']!;
            return PatientDetailScreen(patientId: patientId);
          },
        ),
        GoRoute(
          path: '/doctor/note/:noteId',
          name: 'note_detail',
          builder: (context, state) {
            final noteId = state.pathParameters['noteId']!;
            return NoteDetailScreen(noteId: noteId);
          },
        ),
      ],
      errorBuilder: (context, state) => const NotFoundScreen(),
    );
  }
}
