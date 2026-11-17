import 'package:flutter/material.dart';

import 'models/api_task.dart';
import 'repositories/api_task_repository.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: ApiTestPage()),
  );
}

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final repository = ApiTaskRepository();

  late Future<List<ApiTask>> futureTasks;

  @override
  void initState() {
    super.initState();
    futureTasks = repository.getTasks();
  }

  void reload() {
    setState(() {
      futureTasks = repository.getTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UTH Todo – API Test'),
        actions: [
          IconButton(onPressed: reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<List<ApiTask>>(
        future: futureTasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Text('${snapshot.error}'),
                    FilledButton(
                      onPressed: reload,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          final tasks = snapshot.data ?? [];
          final done = tasks.where((t) => t.done).length;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Kết nối API thành công!',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text('Tổng công việc: ${tasks.length}'),
              Text('Đã hoàn thành: $done'),
              Text('Chưa hoàn thành: ${tasks.length - done}'),
              const SizedBox(height: 20),
              for (final task in tasks)
                Card(
                  child: ListTile(
                    leading: Icon(
                      task.done
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: Colors.blue,
                    ),
                    title: Text(task.title),
                    subtitle: Text(
                      '${task.categoryLabel} • '
                      '${task.date} ${task.time}',
                    ),
                    trailing: Text('${task.id}'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
