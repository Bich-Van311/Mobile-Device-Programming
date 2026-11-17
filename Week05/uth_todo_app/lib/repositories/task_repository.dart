import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task_model.dart';
import '../services/firebase_service.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseService _service = FirebaseService.instance;

  final String userId;

  TaskRepository({required this.userId});

  CollectionReference<Map<String, dynamic>> get _collection {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  void _trackActivity(String event) {
    unawaited(_service.logEvent(event));
    unawaited(_service.updateActivity(userId));
  }

  // READ
  Stream<List<TaskModel>> watchTasks() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(TaskModel.fromFirestore).toList());
  }

  // CREATE
  Future<void> addTask({
    required String title,
    required String description,
    required String category,
  }) async {
    await _collection.add({
      'title': title,
      'description': description,
      'category': category,
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _trackActivity('task_created');
  }

  // UPDATE
  Future<void> updateTask(TaskModel task) async {
    await _collection.doc(task.id).update({
      'title': task.title,
      'description': task.description,
      'category': task.category,
      'completed': task.completed,
    });

    _trackActivity('task_updated');
  }

  // CHANGE STATUS
  Future<void> toggleTask(TaskModel task) async {
    await _collection.doc(task.id).update({'completed': !task.completed});

    _trackActivity('task_status_changed');
  }

  // DELETE
  Future<void> deleteTask(String taskId) async {
    await _collection.doc(taskId).delete();

    _trackActivity('task_deleted');
  }
}
