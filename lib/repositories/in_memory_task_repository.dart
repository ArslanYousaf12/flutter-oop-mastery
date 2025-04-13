import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
  static const String _tasksStorageKey = 'oop_flutter_mastery_tasks';

  // Method to load tasks from shared preferences
  Future<void> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList(_tasksStorageKey);

      if (tasksJson != null && tasksJson.isNotEmpty) {
        _tasks.clear();
        for (final taskJson in tasksJson) {
          final Map<String, dynamic> taskMap = jsonDecode(taskJson);
          _tasks.add(Task.fromJson(taskMap));
        }
      }
    } catch (e) {
      print('Error loading tasks from SharedPreferences: $e');
    }
  }

  // Method to save tasks to shared preferences
  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> tasksJson =
          _tasks.map((task) => jsonEncode(task.toJson())).toList();

      await prefs.setStringList(_tasksStorageKey, tasksJson);
    } catch (e) {
      print('Error saving tasks to SharedPreferences: $e');
    }
  }

  // Implementation of interface methods
  @override
  Future<List<Task>> getAllTasks() async {
    // Make sure tasks are loaded before returning
    if (_tasks.isEmpty) {
      await loadTasks();
    }
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
    await _saveTasks(); // Save after adding
  }

  @override
  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
      await _saveTasks(); // Save after updating
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    await _saveTasks(); // Save after deleting
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
    // Only add sample tasks if the repository is empty
    if (_tasks.isNotEmpty) {
      return;
    }

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
