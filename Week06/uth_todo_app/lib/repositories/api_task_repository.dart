import '../models/api_task.dart';
import '../services/api_service.dart';

class ApiTaskRepository {
  final ApiService _api = ApiService();

  // GET: Lấy danh sách công việc
  Future<List<ApiTask>> getTasks() async {
    final response = await _api.get('/tasks');

    final data = response as List<dynamic>;

    return data
        .map((item) => ApiTask.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  // GET: Xem chi tiết
  Future<ApiTask> getTaskById(int id) async {
    final response = await _api.get('/tasks/$id');

    return ApiTask.fromJson(Map<String, dynamic>.from(response as Map));
  }

  // PATCH: Cập nhật công việc
  Future<void> updateTask(ApiTask task) async {
    final data = task.toJson()..remove('id');

    await _api.patch('/tasks/${task.id}', data);
  }

  // PATCH: Thay đổi trạng thái
  Future<void> toggleTask(ApiTask task) async {
    await _api.patch('/tasks/${task.id}', {'done': !task.done});
  }

  // DELETE: Xóa công việc
  Future<void> deleteTask(int id) async {
    await _api.delete('/tasks/$id');
  }
}
