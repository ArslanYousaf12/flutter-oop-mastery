// Abstract class demonstrating abstraction
import 'package:oop_flutter_mastery/models/project_task.dart';
import 'package:oop_flutter_mastery/models/quick_task.dart';
import 'package:oop_flutter_mastery/models/recurring_task.dart';

abstract class Task {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.isCompleted = false,
  });

  // Abstract method that must be implemented by subclasses
  Duration getEstimatedTime();

  // Method that can be overridden by subclasses
  String getTaskDetails() {
    return 'Task: $title\nDescription: $description\nCreated: $createdAt';
  }

  // Method to mark task as complete
  void markAsComplete() {
    isCompleted = true;
  }

  // Abstract method for converting to JSON - for shared preferences storage
  Map<String, dynamic> toJson();

  // Factory method to create specific task type from JSON
  static Task fromJson(Map<String, dynamic> json) {
    final String type = json['type'];

    switch (type) {
      case 'QuickTask':
        return QuickTask.fromJson(json);
      case 'ProjectTask':
        return ProjectTask.fromJson(json);
      case 'RecurringTask':
        return RecurringTask.fromJson(json);
      default:
        throw Exception('Unknown task type: $type');
    }
  }
}
