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
}
