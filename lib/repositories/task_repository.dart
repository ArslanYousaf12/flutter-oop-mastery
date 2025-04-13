import '../models/task.dart';

// Interface for task repositories - demonstrates abstraction
abstract class TaskRepository {
  // CRUD operations
  Future<List<Task>> getAllTasks();
  Future<Task?> getTaskById(String id);
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);

  // Specialized queries
  Future<List<Task>> getCompletedTasks();
  Future<List<Task>> getIncompleteTasks();
}
