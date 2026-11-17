import 'package:flutter/material.dart';

import '../models/api_task.dart';

class ApiTaskTile extends StatelessWidget {
  final ApiTask task;
  final bool busy;
  final VoidCallback onToggle;
  final VoidCallback onOpen;

  const ApiTaskTile({
    super.key,
    required this.task,
    required this.busy,
    required this.onToggle,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        onTap: onOpen,
        leading: Checkbox(
          value: task.done,
          onChanged: busy ? null : (_) => onToggle(),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: task.done ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text('${task.categoryLabel} • ${task.date} ${task.time}'),
        trailing: task.priority == 'high' && !task.done
            ? const Text(
                'Gấp',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              )
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}

class ApiTaskListPage extends StatefulWidget {
  final List<ApiTask> tasks;
  final Set<int> busyIds;
  final ValueChanged<ApiTask> onToggle;
  final ValueChanged<ApiTask> onOpen;
  final Future<void> Function() onRefresh;

  const ApiTaskListPage({
    super.key,
    required this.tasks,
    required this.busyIds,
    required this.onToggle,
    required this.onOpen,
    required this.onRefresh,
  });

  @override
  State<ApiTaskListPage> createState() => _ApiTaskListPageState();
}

class _ApiTaskListPageState extends State<ApiTaskListPage> {
  String _query = '';
  String _category = 'all';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.tasks.where((t) {
      final matchCategory = _category == 'all' || t.category == _category;

      final matchQuery = '${t.title} ${t.note}'.toLowerCase().contains(
        _query.trim().toLowerCase(),
      );

      return matchCategory && matchQuery;
    }).toList();

    final pending = filtered.where((t) => !t.done).toList();

    final done = filtered.where((t) => t.done).toList();

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Danh sách',
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${widget.tasks.where((t) => !t.done).length} việc chưa xong',
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) {
              setState(() => _query = value);
            },
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Tìm công việc',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final entry in const {
                'all': 'Tất cả',
                'study': 'Học tập',
                'life': 'Cuộc sống',
              }.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: _category == entry.key,
                  onSelected: (_) {
                    setState(() => _category = entry.key);
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Không tìm thấy công việc'),
              ),
            ),
          if (pending.isNotEmpty) ...[
            const Text(
              'CẦN LÀM',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            for (final task in pending) _tile(task),
          ],
          if (done.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'ĐÃ XONG',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            for (final task in done) _tile(task),
          ],
        ],
      ),
    );
  }

  Widget _tile(ApiTask task) {
    return ApiTaskTile(
      task: task,
      busy: widget.busyIds.contains(task.id),
      onToggle: () => widget.onToggle(task),
      onOpen: () => widget.onOpen(task),
    );
  }
}
