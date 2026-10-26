import 'package:flutter/material.dart';

class TodoAppInfo {
  final String name;
  final String slogan;
  final String version;

  const TodoAppInfo({
    required this.name,
    required this.slogan,
    required this.version,
  });
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final List<String> examples;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.examples,
  });
}

class TodoTask {
  final String title;
  final String category;
  bool _completed = false;

  TodoTask({
    required this.title,
    required this.category,
  });

  bool get completed => _completed;

  void toggle() {
    _completed = !_completed;
  }
}

class TodoRepository {
  static const info = TodoAppInfo(
    name: 'UTH Todo',
    slogan: 'Việc học, việc nhà – gọn gàng mỗi ngày',
    version: '2.1.0',
  );

  static const onboarding = <OnboardingItem>[
    OnboardingItem(
      title: 'Mọi việc, gọn trong một chỗ',
      description:
          'Ghi lại bài tập, việc nhà, lịch hẹn. Không còn quên việc nào.',
      icon: Icons.checklist_rounded,
      examples: ['Hoàn thành bài Flutter', 'Đọc sách', 'Dọn góc học tập'],
    ),
    OnboardingItem(
      title: 'Chia theo Học tập và Cuộc sống',
      description: 'Mỗi việc có nhóm riêng, nhìn là biết hôm nay cần làm gì.',
      icon: Icons.category_outlined,
      examples: ['Học tập', 'Cuộc sống'],
    ),
    OnboardingItem(
      title: 'Nhắc đúng lúc',
      description:
          'Sắp xếp thời gian để chủ động hoàn thành công việc trước hạn chót.',
      icon: Icons.notifications_active_outlined,
      examples: ['Ôn bài Toán lúc 19:00'],
    ),
  ];

  final List<TodoTask> _tasks = [
    TodoTask(title: 'Hoàn thành bài tuần 4', category: 'Học tập'),
    TodoTask(title: 'Đọc 10 trang sách', category: 'Cuộc sống'),
    TodoTask(title: 'Ôn tập OOP', category: 'Học tập'),
  ];

  List<TodoTask> get tasks => List.unmodifiable(_tasks);
}
