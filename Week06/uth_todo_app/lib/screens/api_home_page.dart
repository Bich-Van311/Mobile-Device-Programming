import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/api_task.dart';
import '../models/task_model.dart';
import '../repositories/api_task_repository.dart';
import '../services/firebase_service.dart';

import 'api_task_list_page.dart';
import 'api_task_detail_page.dart';
import 'profile_page.dart';
import 'home_page.dart';

class ApiHomePage extends StatefulWidget {
  final User user;

  const ApiHomePage({super.key, required this.user});

  @override
  State<ApiHomePage> createState() => _ApiHomePageState();
}

class _ApiHomePageState extends State<ApiHomePage> {
  static const blue = Color(0xFF3157E9);

  final _repository = ApiTaskRepository();

  final Set<int> _busy = {};
  final Map<int, ApiTask> _sessionTasks = {};
  final Set<int> _deletedIds = {};

  List<ApiTask> _tasks = [];

  bool _loading = true;
  String? _error;
  int _tab = 0;

  @override
  void initState() {
    super.initState();

    unawaited(FirebaseService.instance.updateActivity(widget.user.uid));

    unawaited(_load());
  }

  // GET - Lấy danh sách công việc

  Future<void> _load() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _repository.getTasks();

      if (!mounted) return;

      setState(() {
        _tasks = data
            .where((task) => !_deletedIds.contains(task.id))
            .map((task) => _sessionTasks[task.id] ?? task)
            .toList();
      });
    } catch (error) {
      if (mounted) {
        setState(() => _error = '$error');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // PATCH - Đánh dấu hoàn thành

  Future<void> _toggle(ApiTask task) async {
    if (_busy.contains(task.id)) return;

    setState(() => _busy.add(task.id));

    try {
      await _repository.toggleTask(task);

      if (!mounted) return;

      setState(() {
        _sessionTasks[task.id] = task.copyWith(done: !task.done);

        _tasks = _tasks.map((item) {
          return item.id == task.id ? item.copyWith(done: !task.done) : item;
        }).toList();
      });

      unawaited(FirebaseService.instance.logEvent('task_status_changed'));

      _message('API đã phản hồi thành công!');
    } catch (error) {
      if (mounted) {
        _message('Không cập nhật được: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy.remove(task.id));
      }
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _open(ApiTask task) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ApiTaskDetailPage(
          task: task,
          repository: _repository,
          preferLocal: _sessionTasks.containsKey(task.id),
          onUpdated: (updated) {
            if (!mounted) return;

            setState(() {
              _sessionTasks[updated.id] = updated;

              _tasks = _tasks.map((item) {
                return item.id == updated.id ? updated : item;
              }).toList();
            });
          },
          onDeleted: (id) {
            if (!mounted) return;

            setState(() {
              _deletedIds.add(id);
              _sessionTasks.remove(id);
              _tasks.removeWhere((item) => item.id == id);
            });
          },
        ),
      ),
    );
  }

  void _profile() {
    final tasks = _tasks.map((task) {
      return TaskModel(
        id: '${task.id}',
        title: task.title,
        description: task.note,
        category: task.categoryLabel,
        completed: task.done,
        createdAt: DateTime.tryParse(task.date) ?? DateTime.now(),
      );
    }).toList();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfilePage(user: widget.user, tasks: tasks),
      ),
    );
  }

  // Giữ lại ứng dụng Firebase Week 5

  void _personal() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => HomePage(user: widget.user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text('UTH SmartTasks'),
        actions: [
          IconButton(
            tooltip: 'Tải lại API',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Hồ sơ',
            onPressed: _profile,
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cloud_off,
                            size: 60,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Không tải được dữ liệu: '
                            '$_error',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _load,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  )
                : IndexedStack(
                    index: _tab,
                    children: [
                      _dashboard(),
                      ApiTaskListPage(
                        tasks: _tasks,
                        busyIds: _busy,
                        onToggle: _toggle,
                        onOpen: _open,
                        onRefresh: _load,
                      ),
                    ],
                  ),
          ),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) {
          setState(() => _tab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Danh sách',
          ),
        ],
      ),
    );
  }

  Widget _dashboard() {
    final dates =
        _tasks
            .map((task) => task.date)
            .where((date) => date.isNotEmpty)
            .toList()
          ..sort();

    final sampleDate = dates.isEmpty ? '' : dates.first;

    final now = DateTime.now();

    final todayKey =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    final day = dates.contains(todayKey) ? todayKey : sampleDate;

    final daily = _tasks.where((task) => task.date == day).toList();

    final done = daily.where((task) => task.done).length;

    final ratio = daily.isEmpty ? 0.0 : done / daily.length;

    final name =
        widget.user.displayName ??
        (widget.user.isAnonymous
            ? 'Khách'
            : widget.user.email?.split('@').first ?? 'Bạn');

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _profile,
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFFE0E8FF),
                  child: Text(
                    name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _personal,
                tooltip: 'Công việc cá nhân & thông báo',
                icon: const Icon(Icons.notifications_outlined),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Thống kê tiến độ
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day == todayKey
                            ? 'Tiến độ hôm nay'
                            : 'Tiến độ ngày mẫu $day',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$done/${daily.length} việc',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
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
                  width: 76,
                  height: 76,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: ratio,
                          color: Colors.white,
                          backgroundColor: Colors.white24,
                          strokeWidth: 7,
                        ),
                      ),
                      Text(
                        '${(ratio * 100).round()}%',
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

          const SizedBox(height: 16),

          // Danh mục công việc
          Row(
            children: [
              Expanded(
                child: _category(
                  'study',
                  'Học tập',
                  Icons.school_outlined,
                  blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _category(
                  'life',
                  'Cuộc sống',
                  Icons.home_outlined,
                  Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Text(
                  day == todayKey ? 'Việc hôm nay' : 'Việc ngày mẫu',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _tab = 1);
                },
                child: const Text('Xem tất cả'),
              ),
            ],
          ),

          if (daily.isEmpty) const Text('Chưa có công việc'),

          for (final task in daily)
            ApiTaskTile(
              task: task,
              busy: _busy.contains(task.id),
              onToggle: () => _toggle(task),
              onOpen: () => _open(task),
            ),

          const SizedBox(height: 12),

          const Text(
            'Dữ liệu Mock API; thay đổi được giữ '
            'trong phiên hiện tại.',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),

          TextButton.icon(
            onPressed: _personal,
            icon: const Icon(Icons.cloud_outlined),
            label: const Text('Mở công việc cá nhân Firebase (Week 5)'),
          ),
        ],
      ),
    );
  }

  Widget _category(String key, String label, IconData icon, Color color) {
    final remaining = _tasks
        .where((task) => task.category == key && !task.done)
        .length;

    return Card(
      color: Colors.white,
      elevation: 0,
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
              label,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text('$remaining việc còn lại'),
          ],
        ),
      ),
    );
  }
}
