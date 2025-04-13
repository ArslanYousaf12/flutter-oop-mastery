import 'task.dart';

// QuickTask class demonstrates inheritance
class QuickTask extends Task {
  final Duration estimatedDuration;

  QuickTask({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
    required this.estimatedDuration,
    super.isCompleted = false,
  });

  // Implementation of abstract method from parent class
  @override
  Duration getEstimatedTime() {
    return estimatedDuration;
  }

  // Override of parent method to add more specific details
  @override
  String getTaskDetails() {
    return '${super.getTaskDetails()}\nType: Quick Task\nEstimated time: ${estimatedDuration.inMinutes} minutes';
  }

  // JSON serialization method implementation
  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'QuickTask',
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'estimatedDuration': estimatedDuration.inMicroseconds,
    };
  }

  // Factory method to create QuickTask from JSON
  factory QuickTask.fromJson(Map<String, dynamic> json) {
    return QuickTask(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      isCompleted: json['isCompleted'],
      estimatedDuration: Duration(microseconds: json['estimatedDuration']),
    );
  }
}
