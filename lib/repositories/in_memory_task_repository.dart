import '../models/task.dart';
import '../models/quick_task.dart';
import '../models/project_task.dart';
import '../models/recurring_task.dart';
import 'task_repository.dart';

// Concrete implementation of TaskRepository - demonstrates polymorphism
class InMemoryTaskRepository implements TaskRepository {
  // Singleton pattern - ensures only one instance exists
  static final InMemoryTaskRepository _instance =
      InMemoryTaskRepository._internal();

  factory InMemoryTaskRepository() {
    return _instance;
  }

  InMemoryTaskRepository._internal();

  // Encapsulated state - private field with public access methods
  final List<Task> _tasks = [];

  // Implementation of interface methods
  @override
  Future<List<Task>> getAllTasks() async {
    return _tasks;
  }

  @override
  Future<Task?> getTaskById(String id) async {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addTask(Task task) async {
    _tasks.add(task);
  }

  @override
  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
  }

  @override
  Future<List<Task>> getCompletedTasks() async {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  @override
  Future<List<Task>> getIncompleteTasks() async {
    return _tasks.where((task) => !task.isCompleted).toList();
  }

  // Method to add sample data for demonstration
  Future<void> addSampleTasks() async {
    final now = DateTime.now();

    // Add a quick task
    await addTask(
      QuickTask(
        id: '1',
        title: 'Answer emails',
        description: 'Check and respond to urgent emails',
        createdAt: now,
        estimatedDuration: const Duration(minutes: 30),
      ),
    );

    // Add a project task
    final projectTask = ProjectTask(
      id: '2',
      title: 'Redesign app UI',
      description: 'Update the app UI based on new design guidelines',
      createdAt: now,
      deadline: now.add(const Duration(days: 7)),
      priority: 'High',
    );

    // Adding subtasks to demonstrate composition
    projectTask.addSubTask(
      QuickTask(
        id: '2.1',
        title: 'Create wireframes',
        description: 'Design initial wireframes for approval',
        createdAt: now,
        estimatedDuration: const Duration(hours: 2),
      ),
    );

    projectTask.addSubTask(
      QuickTask(
        id: '2.2',
        title: 'Implement new color scheme',
        description: 'Update app colors to match new branding',
        createdAt: now,
        estimatedDuration: const Duration(hours: 1),
      ),
    );

    await addTask(projectTask);

    // Add a recurring task
    await addTask(
      RecurringTask(
        id: '3',
        title: 'Weekly team meeting',
        description: 'Review progress and discuss blockers',
        createdAt: now,
        frequency: const Duration(days: 7),
        estimatedDuration: const Duration(hours: 1),
        firstDueDate: now.add(const Duration(days: 1)),
      ),
    );
  }
}
