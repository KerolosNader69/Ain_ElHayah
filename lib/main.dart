import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/diagnosis_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/doctor_provider.dart';
import 'providers/huawei_sis_provider.dart';
import 'providers/appointment_provider.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';
import 'services/api_key_loader.dart';
import 'services/voice_chat_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => DiagnosisProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..load()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(
          create: (_) {
            // Voice chat service - uses backend API (secure)
            // TODO: Replace with actual backend URL
            return HuaweiSisProvider(
              service: VoiceChatService(backendUrl: 'http://10.0.2.2:3001'),
            );
          },
        ),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp.router(
            title: 'EyeCloud',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme, // Only dark theme
            locale: appProvider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: AppRouter.createRouter(context),
          );
        },
      ),
    );
  }
}
