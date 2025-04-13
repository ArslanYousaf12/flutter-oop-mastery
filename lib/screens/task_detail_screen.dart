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
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
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

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Task'),
            content: Text(
              'Are you sure you want to delete "${widget.task.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  _taskService.deleteTask(widget.task.id);
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Return to list screen
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('DELETE'),
              ),
            ],
          ),
    );
  }

  Widget _buildTaskHeader() {
    final statusColor = widget.task.isCompleted ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getTaskTypeColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.task.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.task.isCompleted
                          ? Icons.check_circle
                          : Icons.pending,
                      color: statusColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.task.isCompleted ? 'Completed' : 'Pending',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.task.description,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Created: ${_formatDate(widget.task.createdAt)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to get color based on task type
  Color _getTaskTypeColor() {
    if (widget.task is QuickTask) {
      return Colors.blue;
    } else if (widget.task is ProjectTask) {
      return Colors.amber;
    } else if (widget.task is RecurringTask) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade100),
      ),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.hourglass_bottom,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Estimated Time: ${TimeUtils.formatDuration(task.estimatedDuration)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectTaskDetails(ProjectTask task) {
    final daysRemaining = TimeUtils.daysRemaining(task.deadline);
    final isOnTrack = task.isOnTrack();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.amber.shade100),
      ),
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

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Deadline: ${_formatDate(task.deadline)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isOnTrack ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    daysRemaining > 0
                        ? '$daysRemaining ${daysRemaining == 1 ? 'day' : 'days'} left'
                        : 'Overdue',
                    style: TextStyle(
                      color:
                          isOnTrack
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.flag,
                    color: Color(TimeUtils.getPriorityColor(task.priority)),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Priority: ${task.priority}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(TimeUtils.getPriorityColor(task.priority)),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.hourglass_bottom,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total Estimated Time: ${TimeUtils.formatDuration(task.getEstimatedTime())}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Subtasks:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (task.subTasks.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'No subtasks added yet',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              )
            else
              Card(
                margin: const EdgeInsets.only(top: 8),
                color: Colors.white,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: task.subTasks.length,
                  separatorBuilder:
                      (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final subtask = task.subTasks[index];
                    return ListTile(
                      title: Text(subtask.title),
                      subtitle: Text(subtask.description),
                      leading: const Icon(Icons.subdirectory_arrow_right),
                      trailing: Icon(
                        subtask.isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: subtask.isCompleted ? Colors.green : Colors.grey,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurringTaskDetails(RecurringTask task) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.shade100),
      ),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_repeat, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Next Due: ${_formatDate(task.nextDueDate)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.update, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Frequency: ${task.formatFrequency()}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.hourglass_bottom,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Estimated Time: ${TimeUtils.formatDuration(task.estimatedDuration)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Task Recurrence Pattern',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This task repeats ${task.formatFrequency().toLowerCase()}. The next occurrence is scheduled for ${_formatDate(task.nextDueDate)}.',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
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
        onPressed:
            widget.task.isCompleted
                ? null // Disable button if already completed
                : () {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade700,
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
                  'Task rescheduled to ${_formatDate(task.nextDueDate)}',
                ),
              ),
            );
          },
          icon: const Icon(Icons.update),
          label: const Text('Complete & Reschedule'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(spacing: 16, runSpacing: 16, children: actions),
    );
  }
}
