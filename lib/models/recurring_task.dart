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
}
