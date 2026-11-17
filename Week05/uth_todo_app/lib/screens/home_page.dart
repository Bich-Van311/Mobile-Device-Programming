import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import 'profile_page.dart';

import 'dart:async';

import '../services/firebase_service.dart';

import 'package:flutter/services.dart';

import '../services/notification_service.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TaskRepository _repository;
  late final Stream<List<TaskModel>> _taskStream;

  static const blue = Color(0xFF3157E9);

  String _category = 'Tất cả';

  @override
  void initState() {
    super.initState();

    _repository = TaskRepository(userId: widget.user.uid);

    _taskStream = _repository.watchTasks();

    unawaited(FirebaseService.instance.updateActivity(widget.user.uid));
  }

  Future<void> _perform(Future<void> Function() action, String message) async {
    try {
      await action();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thao tác thất bại. Vui lòng thử lại.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _enableNotifications() async {
    try {
      final token = await NotificationService.instance.enableNotifications();

      if (!mounted) return;

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa cấp quyền thông báo.')),
        );
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Đã bật thông báo'),
          content: SingleChildScrollView(child: SelectableText(token)),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: token));

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext);
              },
              child: const Text('Sao chép Token'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi thông báo: $error')));
    }
  }

  Future<void> _showTaskDialog({TaskModel? task}) async {
    final titleController = TextEditingController(text: task?.title ?? '');

    final descriptionController = TextEditingController(
      text: task?.description ?? '',
    );

    String category = task?.category ?? 'Học tập';

    final formKey = GlobalKey<FormState>();

    try {
      final saved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(
                  task == null ? 'Thêm công việc' : 'Chỉnh sửa công việc',
                ),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Tên công việc',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nhập tên công việc';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'Mô tả'),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: category,
                          decoration: const InputDecoration(
                            labelText: 'Danh mục',
                          ),
                          items: ['Học tập', 'Cuộc sống']
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => category = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Hủy'),
                  ),
                  FilledButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      Navigator.pop(dialogContext, true);
                    },
                    child: const Text('Lưu'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (saved != true || !mounted) return;

      final title = titleController.text.trim();

      final description = descriptionController.text.trim();

      if (task == null) {
        await _perform(
          () => _repository.addTask(
            title: title,
            description: description,
            category: category,
          ),
          'Đã thêm công việc!',
        );
      } else {
        await _perform(
          () => _repository.updateTask(
            task.copyWith(
              title: title,
              description: description,
              category: category,
            ),
          ),
          'Đã cập nhật công việc!',
        );
      }
    } finally {
      // Chờ dialog hoàn tất hiệu ứng đóng.
      await Future<void>.delayed(const Duration(milliseconds: 400));

      titleController.dispose();
      descriptionController.dispose();
    }
  }

  Future<void> _deleteTask(TaskModel task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa công việc?'),
        content: Text('Bạn có muốn xóa "${task.title}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _perform(
        () => _repository.deleteTask(task.id),
        'Đã xóa công việc!',
      );
    }
  }

  void _openProfile(List<TaskModel> tasks) {
    unawaited(FirebaseService.instance.logEvent('profile_opened'));

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfilePage(user: widget.user, tasks: tasks),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name =
        widget.user.displayName ??
        (widget.user.isAnonymous
            ? 'Khách'
            : widget.user.email?.split('@').first ?? 'Bạn');

    final now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      floatingActionButton: FloatingActionButton(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        onPressed: () => _showTaskDialog(),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: StreamBuilder<List<TaskModel>>(
          stream: _taskStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Không thể tải dữ liệu.\n'
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final tasks = snapshot.data ?? [];

            final completed = tasks.where((task) => task.completed).length;

            final progress = tasks.isEmpty ? 0.0 : completed / tasks.length;

            final visibleTasks = _category == 'Tất cả'
                ? tasks
                : tasks.where((task) => task.category == _category).toList();

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _openProfile(tasks),
                          child: CircleAvatar(
                            radius: 26,
                            foregroundImage: widget.user.photoURL != null
                                ? NetworkImage(widget.user.photoURL!)
                                : null,
                            child: const Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${now.day}/${now.month}/${now.year}',
                                style: const TextStyle(color: Colors.black54),
                              ),
                              Text(
                                'Chào $name!',
                                style: const TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _enableNotifications,
                          tooltip: 'Bật thông báo',
                          icon: const Icon(Icons.notifications_outlined),
                        ),
                        IconButton(
                          onPressed: () => _openProfile(tasks),
                          icon: const Icon(Icons.settings_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: blue,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tiến độ công việc',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '$completed/${tasks.length} việc',
                                  style: const TextStyle(
                                    fontSize: 30,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  FirebaseService.instance.welcomeMessage,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 78,
                            height: 78,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox.expand(
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 7,
                                    color: Colors.white,
                                    backgroundColor: Colors.white24,
                                  ),
                                ),
                                Text(
                                  '${(progress * 100).round()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _categoryCard(
                            tasks,
                            'Học tập',
                            Icons.school_outlined,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _categoryCard(
                            tasks,
                            'Cuộc sống',
                            Icons.home_outlined,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Công việc của bạn',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _category = 'Tất cả'),
                          child: const Text('Tất cả'),
                        ),
                      ],
                    ),
                    if (visibleTasks.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(36),
                        child: Column(
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 64,
                              color: Colors.black26,
                            ),
                            SizedBox(height: 16),
                            Text('Chưa có công việc'),
                            SizedBox(height: 8),
                            Text(
                              'Nhấn dấu + để thêm công việc mới.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    for (final task in visibleTasks)
                      Card(
                        color: Colors.white,
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: Checkbox(
                            value: task.completed,
                            onChanged: (_) => _perform(
                              () => _repository.toggleTask(task),
                              'Đã cập nhật trạng thái!',
                            ),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              decoration: task.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                            task.description.isEmpty
                                ? task.category
                                : '${task.category}\n'
                                      '${task.description}',
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showTaskDialog(task: task);
                              } else if (value == 'delete') {
                                _deleteTask(task);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Chỉnh sửa'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Xóa'),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _categoryCard(
    List<TaskModel> tasks,
    String category,
    IconData icon,
    Color color,
  ) {
    final remaining = tasks
        .where((task) => task.category == category && !task.completed)
        .length;

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _category == category ? blue : Colors.transparent,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _category = category),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                category,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$remaining việc còn lại',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
