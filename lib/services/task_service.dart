import '../models/task.dart';
import '../repositories/task_repository.dart';

// Service class that demonstrates dependency injection
class TaskService {
  final TaskRepository _repository;

  // Dependency Injection - the repository is injected through the constructor
  TaskService(this._repository);

  Future<List<Task>> getAllTasks() async {
    return await _repository.getAllTasks();
  }

  Future<List<Task>> getCompletedTasks() async {
    return await _repository.getCompletedTasks();
  }

  Future<List<Task>> getIncompleteTasks() async {
    return await _repository.getIncompleteTasks();
  }

  Future<void> addTask(Task task) async {
    await _repository.addTask(task);
  }

  Future<void> markTaskAsComplete(String id) async {
    final task = await _repository.getTaskById(id);
    if (task != null) {
      task.markAsComplete();
      await _repository.updateTask(task);
    }
  }

  Future<void> deleteTask(String id) async {
    await _repository.deleteTask(id);
  }

  // Method to calculate total estimated time for all tasks
  Future<Duration> getTotalEstimatedTime() async {
    final tasks = await _repository.getAllTasks();
    Duration total = const Duration();
    for (var task in tasks) {
      total += task.getEstimatedTime();
    }
    return total;
  }
}
