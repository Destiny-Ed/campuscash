import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/map_provider.dart';
import 'providers/gig_provider.dart';
import 'providers/timetable_provider.dart';
import 'providers/tour_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const CampusCashApp());
}

class CampusCashApp extends StatelessWidget {
  const CampusCashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => GigProvider()),
        ChangeNotifierProvider(create: (_) => TimetableProvider()),
        ChangeNotifierProvider(create: (_) => TourProvider()),
      ],
      child: MaterialApp(
        title: 'CampusCash',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        routes: {
          '/home': (_) => const MainShell(),
        },
      ),
    );
  }
}
