import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'auth_page.dart';
import 'screens/api_home_page.dart';

import 'services/auth_service.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseService.instance.initialize();

  NotificationService.instance.initialize();

  runApp(const UthTodoApp());
}

class UthTodoApp extends StatelessWidget {
  const UthTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: NotificationService.instance.navigatorMessengerKey,

      debugShowCheckedModeBanner: false,
      title: 'UTH SmartTasks',

      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor: const Color(0xFFF5F6FA),

        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3157E9)),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF7F8FC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),

        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),

      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Không thể kiểm tra đăng nhập.')),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const AuthPage();
        }

        return ApiHomePage(key: ValueKey(user.uid), user: user);
      },
    );
  }
}
