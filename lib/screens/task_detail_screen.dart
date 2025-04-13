import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/project_task.dart';
import '../models/quick_task.dart';
import '../models/recurring_task.dart';
import '../services/task_service.dart';
import '../repositories/in_memory_task_repository.dart';
import '../utils/time_utils.dart';

// TaskDetailScreen that demonstrates polymorphism through different UI for each task type
class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TaskService _taskService;

  @override
  void initState() {
    super.initState();
    _taskService = TaskService(InMemoryTaskRepository());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Common task details
            _buildTaskHeader(),
            const SizedBox(height: 24),

            // Type-specific details - demonstrates polymorphic behavior
            _buildSpecificTaskDetails(),

            const SizedBox(height: 24),

            // Task actions - buttons will vary based on task type (polymorphism)
            _buildTaskActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.task.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          widget.task.description,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              widget.task.isCompleted ? Icons.check_circle : Icons.pending,
              color: widget.task.isCompleted ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(
              widget.task.isCompleted ? 'Completed' : 'Pending',
              style: TextStyle(
                color: widget.task.isCompleted ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Polymorphism - different UI based on the task type
  Widget _buildSpecificTaskDetails() {
    if (widget.task is QuickTask) {
      return _buildQuickTaskDetails(widget.task as QuickTask);
    } else if (widget.task is ProjectTask) {
      return _buildProjectTaskDetails(widget.task as ProjectTask);
    } else if (widget.task is RecurringTask) {
      return _buildRecurringTaskDetails(widget.task as RecurringTask);
    } else {
      return const Text('Unknown task type');
    }
  }

  Widget _buildQuickTaskDetails(QuickTask task) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.timer, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Quick Task',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Estimated Time: ${TimeUtils.formatDuration(task.estimatedDuration)}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectTaskDetails(ProjectTask task) {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.folder, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Project Task',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Deadline: ${task.deadline.toString().substring(0, 10)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Priority: ${task.priority}',
              style: TextStyle(
                fontSize: 16,
                color: Color(TimeUtils.getPriorityColor(task.priority)),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Estimated Time: ${TimeUtils.formatDuration(task.getEstimatedTime())}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Subtasks:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: task.subTasks.length,
              itemBuilder: (context, index) {
                final subtask = task.subTasks[index];
                return ListTile(
                  title: Text(subtask.title),
                  subtitle: Text(subtask.description),
                  leading: const Icon(Icons.subdirectory_arrow_right),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurringTaskDetails(RecurringTask task) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.repeat, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Recurring Task',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Next Due: ${task.nextDueDate.toString().substring(0, 10)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Frequency: ${task.formatFrequency()}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Estimated Time: ${TimeUtils.formatDuration(task.estimatedDuration)}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Polymorphism - different actions based on task type
  Widget _buildTaskActions() {
    final actions = <Widget>[
      ElevatedButton.icon(
        onPressed: () {
          _taskService.markTaskAsComplete(widget.task.id);
          setState(() {
            widget.task.markAsComplete();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task marked as complete')),
          );
        },
        icon: const Icon(Icons.check),
        label: const Text('Mark Complete'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
    ];

    // Add type-specific actions (polymorphic behavior)
    if (widget.task is RecurringTask) {
      actions.add(
        ElevatedButton.icon(
          onPressed: () {
            final task = widget.task as RecurringTask;
            task.completeAndReschedule();
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Task rescheduled to ${task.nextDueDate.toString().substring(0, 10)}',
                ),
              ),
            );
          },
          icon: const Icon(Icons.update),
          label: const Text('Complete & Reschedule'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    return Wrap(spacing: 16, runSpacing: 16, children: actions);
  }
}
