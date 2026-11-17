import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task_model.dart';
import '../services/auth_service.dart';

import 'dart:async';

class ProfilePage extends StatelessWidget {
  final User user;
  final List<TaskModel> tasks;

  const ProfilePage({super.key, required this.user, required this.tasks});

  Future<void> _logout(BuildContext context) async {
    try {
      await AuthService().signOut();

      if (!context.mounted) return;

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đăng xuất thất bại.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = tasks.where((task) => task.completed).length;

    final pending = tasks.length - completed;

    final percent = tasks.isEmpty
        ? 0
        : (completed / tasks.length * 100).round();

    final googleLinked = user.providerData.any(
      (provider) => provider.providerId == 'google.com',
    );

    final name =
        user.displayName ??
        (user.isAnonymous
            ? 'Người dùng khách'
            : user.email?.split('@').first ?? 'Người dùng UTH Todo');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Hồ sơ'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F6FA),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 16),
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFFE0E8FF),
                    foregroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: const Icon(Icons.person_outline, size: 50),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email ?? 'Chế độ dùng thử',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Chip(
                    avatar: Icon(
                      googleLinked
                          ? Icons.verified_user
                          : Icons.account_circle_outlined,
                      size: 18,
                      color: Colors.green,
                    ),
                    label: Text(
                      googleLinked
                          ? 'Đã liên kết tài khoản Google'
                          : user.isAnonymous
                          ? 'Tài khoản ẩn danh'
                          : 'Tài khoản Email',
                    ),
                    backgroundColor: const Color(0xFFE8F5E9),
                    side: BorderSide.none,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    _stat('$completed', 'Đã xong'),
                    _stat('$pending', 'Đang chờ'),
                    _stat('$percent%', 'Hoàn thành'),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  color: Colors.white,
                  elevation: 0,
                  child: ListTile(
                    leading: const Icon(Icons.verified_user_outlined),
                    title: const Text('Mã người dùng'),
                    subtitle: Text(user.uid),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Colors.white,
                  elevation: 0,
                  child: ListTile(
                    leading: const Icon(Icons.cloud_done_outlined),
                    title: const Text('Firebase Authentication'),
                    subtitle: const Text('Đã xác thực'),
                  ),
                ),
                const SizedBox(height: 36),
                OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Đăng xuất'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    minimumSize: const Size(0, 52),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Card(
        color: Colors.white,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3157E9),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
