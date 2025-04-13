import 'task.dart';

// RecurringTask demonstrates inheritance and specialized behavior
class RecurringTask extends Task {
  final Duration frequency; // How often the task repeats
  final Duration estimatedDuration;
  DateTime nextDueDate;

  RecurringTask({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
    required this.frequency,
    required this.estimatedDuration,
    required DateTime firstDueDate,
    super.isCompleted = false,
  }) : nextDueDate = firstDueDate;

  @override
  Duration getEstimatedTime() {
    return estimatedDuration;
  }

  @override
  String getTaskDetails() {
    return '${super.getTaskDetails()}\nType: Recurring Task\nNext due: $nextDueDate\nFrequency: ${formatFrequency()}';
  }

  // Specialized method for recurring tasks
  void completeAndReschedule() {
    markAsComplete();
    nextDueDate = nextDueDate.add(frequency);
    isCompleted = false; // Reset for next occurrence
  }

  // Public method to format frequency (accessible from outside)
  String formatFrequency() {
    return _formatFrequency();
  }

  // Encapsulated helper method
  String _formatFrequency() {
    if (frequency.inDays > 0) {
      return 'Every ${frequency.inDays} ${frequency.inDays == 1 ? 'day' : 'days'}';
    } else if (frequency.inHours > 0) {
      return 'Every ${frequency.inHours} ${frequency.inHours == 1 ? 'hour' : 'hours'}';
    } else {
      return 'Every ${frequency.inMinutes} ${frequency.inMinutes == 1 ? 'minute' : 'minutes'}';
    }
  }

  // JSON serialization implementation
  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'RecurringTask',
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'frequency': frequency.inMicroseconds,
      'estimatedDuration': estimatedDuration.inMicroseconds,
      'nextDueDate': nextDueDate.toIso8601String(),
    };
  }

  // Factory method to create RecurringTask from JSON
  factory RecurringTask.fromJson(Map<String, dynamic> json) {
    return RecurringTask(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      isCompleted: json['isCompleted'],
      frequency: Duration(microseconds: json['frequency']),
      estimatedDuration: Duration(microseconds: json['estimatedDuration']),
      firstDueDate: DateTime.parse(json['nextDueDate']),
    );
  }
}
