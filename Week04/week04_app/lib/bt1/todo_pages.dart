import 'package:flutter/material.dart';

import 'todo_models.dart';

const todoBlue = Color(0xFF3157E9);

class TodoSplashPage extends StatefulWidget {
  const TodoSplashPage({super.key});

  @override
  State<TodoSplashPage> createState() => _TodoSplashPageState();
}

class _TodoSplashPageState extends State<TodoSplashPage> {
  @override
  void initState() {
    super.initState();
    _openNextPage();
  }

  Future<void> _openNextPage() async {
    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const TodoOnboardingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = TodoRepository.info;

    return Scaffold(
      backgroundColor: todoBlue,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.checklist_rounded,
                          size: 60,
                          color: todoBlue,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        info.name,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        info.slogan,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                color: Colors.white,
                backgroundColor: Colors.white24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Phiên bản ${info.version}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class TodoOnboardingPage extends StatefulWidget {
  const TodoOnboardingPage({super.key});

  @override
  State<TodoOnboardingPage> createState() => _TodoOnboardingPageState();
}

class _TodoOnboardingPageState extends State<TodoOnboardingPage> {
  final PageController _controller = PageController();
  int _index = 0;

  void _openHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => TodoHomePage(repository: TodoRepository()),
      ),
    );
  }

  void _next() {
    if (_index == TodoRepository.onboarding.length - 1) {
      _openHome();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = TodoRepository.onboarding;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                children: [
                  const Icon(Icons.checklist, color: todoBlue),
                  const SizedBox(width: 8),
                  Text(
                    TodoRepository.info.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton(onPressed: _openHome, child: const Text('Bỏ qua')),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: items.length,
                onPageChanged: (value) {
                  setState(() => _index = value);
                },
                itemBuilder: (context, index) {
                  final item = items[index];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 35),
                        Center(
                          child: Container(
                            width: 250,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDF0FF),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Column(
                              children: [
                                Icon(item.icon, size: 80, color: todoBlue),
                                const SizedBox(height: 20),
                                for (final example in item.examples)
                                  Card(
                                    child: ListTile(
                                      dense: true,
                                      leading: const Icon(
                                        Icons.check_circle_outline,
                                        color: todoBlue,
                                      ),
                                      title: Text(example),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: List.generate(
                      items.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 6),
                        width: index == _index ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: index == _index
                              ? todoBlue
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _next,
                      child: Text(
                        _index == items.length - 1
                            ? 'Bắt đầu ngay'
                            : 'Tiếp tục',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  final TodoRepository repository;

  const TodoHomePage({super.key, required this.repository});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(TodoRepository.info.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Công việc hôm nay',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          for (final task in widget.repository.tasks)
            Card(
              child: CheckboxListTile(
                value: task.completed,
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                subtitle: Text(task.category),
                onChanged: (_) => setState(task.toggle),
              ),
            ),
        ],
      ),
    );
  }
}
