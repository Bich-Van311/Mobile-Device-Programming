import 'package:flutter/material.dart';

import 'bt1/todo_pages.dart';
import 'bt2/library_page.dart';
import 'bt3/reset_pages.dart';

void main() {
  runApp(const Week04App());
}

class Week04App extends StatelessWidget {
  const Week04App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Week 04',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
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
      home: const ExerciseMenuPage(),
    );
  }
}

class Exercise {
  final String title;
  final String description;
  final IconData icon;
  final WidgetBuilder builder;

  const Exercise({
    required this.title,
    required this.description,
    required this.icon,
    required this.builder,
  });
}

class ExerciseMenuPage extends StatelessWidget {
  const ExerciseMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final exercises = <Exercise>[
      Exercise(
        title: 'BT1 — UTH Todo',
        description: 'Navigation + OOP',
        icon: Icons.checklist_rounded,
        builder: (_) => const TodoSplashPage(),
      ),
      Exercise(
        title: 'BT2 — Quản lý Thư viện',
        description: 'Bốn đặc trưng của OOP',
        icon: Icons.local_library_outlined,
        builder: (_) => const LibraryPage(),
      ),
      Exercise(
        title: 'BT3 — Data Flow',
        description: 'Truyền và nhận dữ liệu giữa các màn hình',
        icon: Icons.swap_horiz_rounded,
        builder: (_) => const EmailPage(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Bài tập tuần 4'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          const Text(
            'Navigation & OOP',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Chọn bài tập để chạy demo.'),
          const SizedBox(height: 28),
          for (final exercise in exercises)
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(18),
                leading: Icon(
                  exercise.icon,
                  size: 32,
                  color: const Color(0xFF3157E9),
                ),
                title: Text(
                  exercise.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(exercise.description),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(builder: exercise.builder),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
