import 'package:flutter/material.dart';

import '../models/api_task.dart';
import '../repositories/api_task_repository.dart';

class ApiTaskDetailPage extends StatefulWidget {
  final ApiTask task;
  final ApiTaskRepository repository;
  final ValueChanged<ApiTask> onUpdated;
  final ValueChanged<int> onDeleted;
  final bool preferLocal;

  const ApiTaskDetailPage({
    super.key,
    required this.task,
    required this.repository,
    required this.onUpdated,
    required this.onDeleted,
    this.preferLocal = false,
  });

  @override
  State<ApiTaskDetailPage> createState() => _ApiTaskDetailPageState();
}

class _ApiTaskDetailPageState extends State<ApiTaskDetailPage> {
  late ApiTask _task;

  bool _loading = true;
  bool _saving = false;
  String? _warning;

  static const blue = Color(0xFF3157E9);

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _loadDetail();
  }

  // GET - Lấy chi tiết công việc
  Future<void> _loadDetail() async {
    try {
      final result = await widget.repository.getTaskById(widget.task.id);

      if (!mounted) return;

      setState(() {
        if (result.id != widget.task.id) {
          _warning = 'Mock API trả về dữ liệu mẫu khác ID.';
        } else if (!widget.preferLocal) {
          _task = result;
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _warning = 'Đang hiển thị dữ liệu từ danh sách.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // PATCH - Cập nhật công việc
  Future<void> _save(ApiTask updated) async {
    if (_saving) return;

    setState(() => _saving = true);

    try {
      await widget.repository.updateTask(updated);

      if (!mounted) return;

      setState(() => _task = updated);

      widget.onUpdated(updated);

      _message('Cập nhật thành công!');
    } catch (error) {
      if (mounted) {
        _message('Cập nhật thất bại: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _editTask() async {
    final result = await showDialog<ApiTask>(
      context: context,
      builder: (_) => _EditTaskDialog(task: _task),
    );

    if (result != null && mounted) {
      await _save(result);
    }
  }

  Future<void> _editSubtask({int? index}) async {
    if (_saving) return;

    final result = await showDialog<String>(
      context: context,
      builder: (_) => _SubtaskDialog(
        initialValue: index == null ? '' : _task.subtasks[index].title,
      ),
    );

    if (result == null || !mounted) return;

    final subtasks = List<SubTask>.from(_task.subtasks);

    if (index == null) {
      subtasks.add(SubTask(title: result, done: false));
    } else {
      subtasks[index] = SubTask(title: result, done: subtasks[index].done);
    }

    await _save(_task.copyWith(subtasks: subtasks));
  }

  Future<void> _toggleSubtask(int index) async {
    final subtasks = List<SubTask>.from(_task.subtasks);

    final old = subtasks[index];

    subtasks[index] = SubTask(title: old.title, done: !old.done);

    await _save(_task.copyWith(subtasks: subtasks));
  }

  Future<void> _deleteSubtask(int index) async {
    final subtasks = List<SubTask>.from(_task.subtasks);

    subtasks.removeAt(index);

    await _save(_task.copyWith(subtasks: subtasks));
  }

  // DELETE - Xóa công việc
  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa công việc?'),
        content: Text('Bạn có muốn xóa "${_task.title}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted || _saving) return;

    setState(() => _saving = true);

    try {
      await widget.repository.deleteTask(_task.id);

      if (!mounted) return;

      widget.onDeleted(_task.id);

      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        _message('Không thể xóa: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = _task.subtasks.where((t) => t.done).length;

    final progress = _task.subtasks.isEmpty
        ? 0.0
        : completed / _task.subtasks.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text('Chi tiết công việc'),
        actions: [
          TextButton(
            onPressed: _saving || _loading ? null : _editTask,
            child: const Text('Sửa'),
          ),
        ],
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (_saving) const LinearProgressIndicator(),

                    if (_warning != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _warning!,
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ),

                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(label: Text(_task.categoryLabel)),
                        Chip(label: Text(_task.priorityLabel)),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      _task.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Card(
                      color: Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: const Text('Hạn chót'),
                            subtitle: Text('${_task.date} ${_task.time}'),
                          ),
                          SwitchListTile(
                            secondary: const Icon(Icons.notifications_outlined),
                            title: const Text('Nhắc nhở'),
                            value: _task.remind,
                            onChanged: _saving
                                ? null
                                : (value) =>
                                      _save(_task.copyWith(remind: value)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Ghi chú',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _task.note.isEmpty ? 'Không có ghi chú' : _task.note,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Việc nhỏ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text('$completed/${_task.subtasks.length}'),
                      ],
                    ),

                    const SizedBox(height: 10),

                    LinearProgressIndicator(value: progress, color: blue),

                    const SizedBox(height: 12),

                    for (int i = 0; i < _task.subtasks.length; i++)
                      Card(
                        color: Colors.white,
                        child: ListTile(
                          leading: Checkbox(
                            value: _task.subtasks[i].done,
                            onChanged: _saving
                                ? null
                                : (_) => _toggleSubtask(i),
                          ),
                          title: Text(
                            _task.subtasks[i].title,
                            style: TextStyle(
                              decoration: _task.subtasks[i].done
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: _saving
                                    ? null
                                    : () => _editSubtask(index: i),
                                icon: const Icon(Icons.edit_outlined, size: 20),
                              ),
                              IconButton(
                                onPressed: _saving
                                    ? null
                                    : () => _deleteSubtask(i),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    TextButton.icon(
                      onPressed: _saving ? null : () => _editSubtask(),
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm việc nhỏ'),
                    ),

                    const SizedBox(height: 32),

                    FilledButton(
                      onPressed: _saving
                          ? null
                          : () => _save(_task.copyWith(done: !_task.done)),
                      child: Text(
                        _task.done
                            ? 'Đánh dấu chưa hoàn thành'
                            : 'Đánh dấu hoàn thành',
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: _saving ? null : _deleteTask,
                      child: const Text(
                        'Xóa công việc',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _SubtaskDialog extends StatefulWidget {
  final String initialValue;

  const _SubtaskDialog({required this.initialValue});

  @override
  State<_SubtaskDialog> createState() => _SubtaskDialogState();
}

class _SubtaskDialogState extends State<_SubtaskDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Việc nhỏ'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(labelText: 'Tên việc nhỏ'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () {
            final text = _controller.text.trim();

            if (text.isNotEmpty) {
              Navigator.pop(context, text);
            }
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

class _EditTaskDialog extends StatefulWidget {
  final ApiTask task;

  const _EditTaskDialog({required this.task});

  @override
  State<_EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<_EditTaskDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _title;
  late final TextEditingController _note;
  late final TextEditingController _date;
  late final TextEditingController _time;

  late String _category;
  late String _priority;

  @override
  void initState() {
    super.initState();

    _title = TextEditingController(text: widget.task.title);
    _note = TextEditingController(text: widget.task.note);
    _date = TextEditingController(text: widget.task.date);
    _time = TextEditingController(text: widget.task.time);

    _category = widget.task.category;
    _priority = widget.task.priority;
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    _date.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chỉnh sửa công việc'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Tên công việc'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nhập tên công việc';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _note,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Ghi chú'),
                ),

                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Danh mục'),
                  items: const [
                    DropdownMenuItem(value: 'study', child: Text('Học tập')),
                    DropdownMenuItem(value: 'life', child: Text('Cuộc sống')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _category = value);
                    }
                  },
                ),

                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  initialValue: _priority,
                  decoration: const InputDecoration(labelText: 'Độ ưu tiên'),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Thấp')),
                    DropdownMenuItem(value: 'medium', child: Text('Vừa')),
                    DropdownMenuItem(value: 'high', child: Text('Cao')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _priority = value);
                    }
                  },
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _date,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Ngày thực hiện',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final selected = await showDatePicker(
                      context: context,
                      initialDate:
                          DateTime.tryParse(_date.text) ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );

                    if (selected != null && mounted) {
                      _date.text = selected.toIso8601String().split('T').first;
                    }
                  },
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _time,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Thời gian',
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  onTap: () async {
                    final selected = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (selected != null && mounted) {
                      _time.text =
                          '${selected.hour.toString().padLeft(2, '0')}:'
                          '${selected.minute.toString().padLeft(2, '0')}';
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            Navigator.pop(
              context,
              widget.task.copyWith(
                title: _title.text.trim(),
                note: _note.text.trim(),
                category: _category,
                priority: _priority,
                date: _date.text,
                time: _time.text,
              ),
            );
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
