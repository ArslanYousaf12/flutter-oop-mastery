// Utility class with static methods - demonstrates encapsulation and reusability
class TimeUtils {
  // Private constructor prevents instantiation
  TimeUtils._();

  // Static method to format duration in a human-readable way
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ${minutes > 0 ? '$minutes ${minutes == 1 ? 'minute' : 'minutes'}' : ''}';
    } else {
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    }
  }

  // Static method to determine the priority color
  static int getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 0xFFE57373; // Red
      case 'medium':
        return 0xFFFFD54F; // Yellow
      case 'low':
        return 0xFF81C784; // Green
      default:
        return 0xFF90CAF9; // Blue (default)
    }
  }

  // Static method to calculate days remaining
  static int daysRemaining(DateTime deadline) {
    final now = DateTime.now();
    return deadline.difference(now).inDays;
  }
}

// Extension method on String - demonstrates extension methods
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
