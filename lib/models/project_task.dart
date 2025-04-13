import 'task.dart';

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
}
