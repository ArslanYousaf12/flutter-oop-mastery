// Abstract class demonstrating abstraction
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
}
