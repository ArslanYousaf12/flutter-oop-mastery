import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/project_task.dart';
import '../models/quick_task.dart';
import '../models/recurring_task.dart';
import '../services/task_service.dart';
import '../repositories/in_memory_task_repository.dart';
import '../utils/time_utils.dart';
import 'task_detail_screen.dart';

// TaskListScreen demonstrates how to use polymorphism in the UI
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // Using dependency injection to get the service
  final TaskService _taskService = TaskService(InMemoryTaskRepository());
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);

    try {
      // Get the singleton instance and use it directly
      final repository = InMemoryTaskRepository();

      // Add sample tasks for demonstration
      await repository.addSampleTasks();

      // Load tasks from repository
      final tasks = await _taskService.getAllTasks();

      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading tasks: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Master'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _tasks.isEmpty
              ? const Center(child: Text('No tasks yet! Tap + to add a task.'))
              : ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return _buildTaskCard(context, task);
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show task creation dialog - this demonstrates polymorphism in action
          _showAddTaskDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Shows dialog to add a new task - demonstrates Factory pattern and polymorphism
  void _showAddTaskDialog(BuildContext context) {
    String taskType = 'quick'; // Default type
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    // Controllers for specific task types
    final durationController = TextEditingController(text: '30');
    final priorityController = TextEditingController(text: 'Medium');
    final deadlineController = TextEditingController(
      text: DateTime.now()
          .add(const Duration(days: 7))
          .toString()
          .substring(0, 10),
    );
    final frequencyController = TextEditingController(text: '7');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task type selection
                    const Text(
                      'Task Type:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: taskType,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: 'quick',
                          child: Text('Quick Task'),
                        ),
                        DropdownMenuItem(
                          value: 'project',
                          child: Text('Project Task'),
                        ),
                        DropdownMenuItem(
                          value: 'recurring',
                          child: Text('Recurring Task'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          taskType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Common fields for all task types
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Type-specific fields (demonstrating polymorphism in UI)
                    if (taskType == 'quick') ...[
                      TextField(
                        controller: durationController,
                        decoration: const InputDecoration(
                          labelText: 'Duration (minutes)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ] else if (taskType == 'project') ...[
                      TextField(
                        controller: priorityController,
                        decoration: const InputDecoration(
                          labelText: 'Priority (High/Medium/Low)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: deadlineController,
                        decoration: const InputDecoration(
                          labelText: 'Deadline (YYYY-MM-DD)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ] else if (taskType == 'recurring') ...[
                      TextField(
                        controller: frequencyController,
                        decoration: const InputDecoration(
                          labelText: 'Repeat every (days)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: durationController,
                        decoration: const InputDecoration(
                          labelText: 'Duration (minutes)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _createAndAddTask(
                      taskType,
                      titleController.text,
                      descriptionController.text,
                      durationController.text,
                      priorityController.text,
                      deadlineController.text,
                      frequencyController.text,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Factory method pattern - creates different task types based on input
  Future<void> _createAndAddTask(
    String taskType,
    String title,
    String description,
    String duration,
    String priority,
    String deadline,
    String frequency,
  ) async {
    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and description are required')),
      );
      return;
    }

    final now = DateTime.now();
    final String id = '${now.millisecondsSinceEpoch}';
    Task newTask;

    // Create task based on type - demonstrates polymorphism and factory pattern
    switch (taskType) {
      case 'quick':
        final durationMinutes = int.tryParse(duration) ?? 30;
        newTask = QuickTask(
          id: id,
          title: title,
          description: description,
          createdAt: now,
          estimatedDuration: Duration(minutes: durationMinutes),
        );
        break;

      case 'project':
        DateTime deadlineDate;
        try {
          deadlineDate = DateTime.parse(deadline);
        } catch (_) {
          deadlineDate = now.add(const Duration(days: 7));
        }

        newTask = ProjectTask(
          id: id,
          title: title,
          description: description,
          createdAt: now,
          deadline: deadlineDate,
          priority: priority.isEmpty ? 'Medium' : priority,
        );
        break;

      case 'recurring':
        final durationMinutes = int.tryParse(duration) ?? 30;
        final repeatDays = int.tryParse(frequency) ?? 7;

        newTask = RecurringTask(
          id: id,
          title: title,
          description: description,
          createdAt: now,
          frequency: Duration(days: repeatDays),
          estimatedDuration: Duration(minutes: durationMinutes),
          firstDueDate: now.add(Duration(days: 1)),
        );
        break;

      default:
        return;
    }

    // Add the task to the repository
    await _taskService.addTask(newTask);

    // Refresh the list
    final tasks = await _taskService.getAllTasks();
    setState(() {
      _tasks = tasks;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${taskType.capitalize()} task added')),
    );
  }

  // Demonstrates polymorphism - rendering different cards based on the task type
  Widget _buildTaskCard(BuildContext context, Task task) {
    // Shared card appearance
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(task.title),
        subtitle: Text(task.description),
        trailing: _buildTaskTypeIcon(task),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(task: task),
            ),
          ).then((_) => _refreshTasks());
        },
      ),
    );
  }

  // Helper method to refresh tasks after returning from detail screen
  Future<void> _refreshTasks() async {
    final tasks = await _taskService.getAllTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  // Demonstrates polymorphism - different icons based on task type
  Widget _buildTaskTypeIcon(Task task) {
    if (task is QuickTask) {
      return const Icon(Icons.timer, color: Colors.blue);
    } else if (task is ProjectTask) {
      return const Icon(Icons.folder, color: Colors.amber);
    } else if (task is RecurringTask) {
      return const Icon(Icons.repeat, color: Colors.green);
    } else {
      return const Icon(Icons.task_alt);
    }
  }
}
