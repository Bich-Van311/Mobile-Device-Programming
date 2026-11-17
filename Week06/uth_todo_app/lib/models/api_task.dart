class SubTask {
  final String title;
  final bool done;

  const SubTask({required this.title, required this.done});

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      title: json['title'] as String? ?? '',
      done: json['done'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {'title': title, 'done': done};
}

class ApiTask {
  final int id;
  final String title;
  final String note;
  final String category;
  final String date;
  final String time;
  final String priority;
  final bool remind;
  final bool done;
  final List<SubTask> subtasks;

  const ApiTask({
    required this.id,
    required this.title,
    required this.note,
    required this.category,
    required this.date,
    required this.time,
    required this.priority,
    required this.remind,
    required this.done,
    required this.subtasks,
  });

  factory ApiTask.fromJson(Map<String, dynamic> json) {
    return ApiTask(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      note: json['note'] as String? ?? '',
      category: json['category'] as String? ?? 'study',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      priority: json['priority'] as String? ?? 'medium',
      remind: json['remind'] as bool? ?? false,
      done: json['done'] as bool? ?? false,
      subtasks: (json['subtasks'] as List? ?? [])
          .map(
            (item) => SubTask.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'note': note,
    'category': category,
    'date': date,
    'time': time,
    'priority': priority,
    'remind': remind,
    'done': done,
    'subtasks': subtasks.map((s) => s.toJson()).toList(),
  };

  String get categoryLabel {
    switch (category) {
      case 'study':
        return 'Học tập';
      case 'life':
        return 'Cuộc sống';
      default:
        return category;
    }
  }

  String get priorityLabel {
    switch (priority) {
      case 'high':
        return 'Ưu tiên cao';
      case 'medium':
        return 'Ưu tiên vừa';
      case 'low':
        return 'Ưu tiên thấp';
      default:
        return priority;
    }
  }

  ApiTask copyWith({
    String? title,
    String? note,
    String? category,
    String? date,
    String? time,
    String? priority,
    bool? remind,
    bool? done,
    List<SubTask>? subtasks,
  }) {
    return ApiTask(
      id: id,
      title: title ?? this.title,
      note: note ?? this.note,
      category: category ?? this.category,
      date: date ?? this.date,
      time: time ?? this.time,
      priority: priority ?? this.priority,
      remind: remind ?? this.remind,
      done: done ?? this.done,
      subtasks: subtasks ?? this.subtasks,
    );
  }
}
