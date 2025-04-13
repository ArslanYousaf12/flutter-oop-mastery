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

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  // Using dependency injection to get the service
  final TaskService _taskService = TaskService(InMemoryTaskRepository());
  List<Task> _tasks = [];
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadTasks();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              _showTaskStats(context);
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _tasks.isEmpty
              ? _buildEmptyState()
              : _buildTaskList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show task creation dialog - this demonstrates polymorphism in action
          _showAddTaskDialog(context);
        },
        child: const Icon(Icons.add),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks yet!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add a task',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    // Using ListView.builder instead of AnimatedList for better stability
    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return Dismissible(
          key: Key(task.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Task'),
                content: Text(
                  'Are you sure you want to delete "${task.title}"?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('DELETE'),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) {
            _deleteTask(task.id);
          },
          child: _buildTaskCard(context, task),
        );
      },
    );
  }

  // Shows a dialog with task statistics
  void _showTaskStats(BuildContext context) async {
    final totalTasks = _tasks.length;
    final completedTasks = _tasks.where((task) => task.isCompleted).length;
    final incompleteTasks = totalTasks - completedTasks;
    final totalEstimatedTime = await _taskService.getTotalEstimatedTime();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Task Statistics'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatRow('Total Tasks', totalTasks.toString()),
                _buildStatRow('Completed', completedTasks.toString()),
                _buildStatRow('Pending', incompleteTasks.toString()),
                _buildStatRow(
                  'Total Estimated Time',
                  TimeUtils.formatDuration(totalEstimatedTime),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: totalTasks > 0 ? completedTasks / totalTasks : 0,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    totalTasks > 0
                        ? '${(completedTasks / totalTasks * 100).toStringAsFixed(1)}% complete'
                        : 'No tasks yet',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CLOSE'),
              ),
            ],
          ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Delete a task from the repository
  Future<void> _deleteTask(String id) async {
    await _taskService.deleteTask(id);
    _refreshTasks();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            // In a real app, you would implement undo functionality here
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Undo is not implemented in this demo'),
              ),
            );
          },
        ),
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
    // Get type-specific color
    final typeColor =
        task is QuickTask
            ? Colors.blue
            : task is ProjectTask
            ? Colors.amber
            : task is RecurringTask
            ? Colors.green
            : Colors.grey;

    // Get completion status
    final isCompleted = task.isCompleted;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: typeColor.withOpacity(0.3), width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: typeColor, width: 6)),
        ),
        child: Column(
          children: [
            ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isCompleted
                              ? Colors.green.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isCompleted ? 'Done' : 'Pending',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isCompleted
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[700],
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              leading: CircleAvatar(
                backgroundColor: typeColor.withOpacity(0.2),
                child: Icon(_getTaskTypeIcon(task), color: typeColor, size: 20),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskDetailScreen(task: task),
                  ),
                ).then((_) => _refreshTasks());
              },
            ),

            // Type-specific details section at the bottom
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Show time info for all tasks
                  Text(
                    'Estimated: ${_getEstimatedTimeText(task)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),

                  // Type-specific extra info
                  if (task is ProjectTask)
                    Text(
                      'Due: ${_formatDate(task.deadline)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            TimeUtils.daysRemaining(task.deadline) < 0
                                ? Colors.red
                                : TimeUtils.daysRemaining(task.deadline) < 2
                                ? Colors.orange
                                : Colors.grey[700],
                      ),
                    )
                  else if (task is RecurringTask)
                    Text(
                      'Next: ${_formatDate(task.nextDueDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTaskTypeIcon(Task task) {
    if (task is QuickTask) {
      return Icons.timer;
    } else if (task is ProjectTask) {
      return Icons.folder;
    } else if (task is RecurringTask) {
      return Icons.repeat;
    } else {
      return Icons.task_alt;
    }
  }

  String _getEstimatedTimeText(Task task) {
    final duration = task.getEstimatedTime();
    return TimeUtils.formatDuration(duration);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Helper method to refresh tasks
  Future<void> _refreshTasks() async {
    final tasks = await _taskService.getAllTasks();
    setState(() {
      _tasks = tasks;
    });
  }
}
