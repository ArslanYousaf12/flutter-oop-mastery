import 'task.dart';
import 'quick_task.dart';

// ProjectTask class demonstrates both inheritance and composition
class ProjectTask extends Task {
  // Changed from final to late final and made it a mutable list
  late final List<Task> subTasks;
  final DateTime deadline;
  final String priority;

  ProjectTask({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
    required this.deadline,
    required this.priority,
    List<Task>? subTasks,
    super.isCompleted = false,
  }) {
    // Initialize with an empty mutable list or the provided list
    this.subTasks = subTasks?.toList() ?? [];
  }

  // Implementation of the abstract method
  @override
  Duration getEstimatedTime() {
    // Calculate total estimated time from all subtasks
    Duration totalDuration = const Duration();
    for (var task in subTasks) {
      totalDuration += task.getEstimatedTime();
    }
    return totalDuration;
  }

  // Override with project-specific details
  @override
  String getTaskDetails() {
    return '${super.getTaskDetails()}\nType: Project Task\nDeadline: $deadline\nPriority: $priority\nSubtasks: ${subTasks.length}';
  }

  // Add a method to add subtasks - demonstrates encapsulation
  void addSubTask(Task task) {
    subTasks.add(task);
  }

  // Check if project is on track
  bool isOnTrack() {
    return DateTime.now().isBefore(deadline);
  }

  // JSON serialization implementation
  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'ProjectTask',
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'deadline': deadline.toIso8601String(),
      'priority': priority,
      'subTasks': subTasks.map((task) => task.toJson()).toList(),
    };
  }

  // Factory method to create ProjectTask from JSON
  factory ProjectTask.fromJson(Map<String, dynamic> json) {
    final projectTask = ProjectTask(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      isCompleted: json['isCompleted'],
      deadline: DateTime.parse(json['deadline']),
      priority: json['priority'],
    );

    // Add subtasks if any
    if (json['subTasks'] != null) {
      for (var taskJson in json['subTasks']) {
        projectTask.addSubTask(Task.fromJson(taskJson));
      }
    }

    return projectTask;
  }
}
