import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/user.dart';
import '../../core/widgets/permission_widget.dart';
import 'cubit/task_cubit.dart';
import 'cubit/task_state.dart';
import 'create_task_page.dart';

class TaskManagementPage extends StatefulWidget {
  const TaskManagementPage({Key? key}) : super(key: key);

  @override
  State<TaskManagementPage> createState() => _TaskManagementPageState();
}

class _TaskManagementPageState extends State<TaskManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TaskStatus? _filterStatus;
  TaskType? _filterType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<TaskCubit>().loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Tasks', icon: Icon(Icons.list)),
            Tab(text: 'My Tasks', icon: Icon(Icons.person)),
            Tab(text: 'Overdue', icon: Icon(Icons.warning)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: () => context.read<TaskCubit>().loadTasks(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocConsumer<TaskCubit, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is TaskUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<TaskCubit>().loadTasks();
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildAllTasksTab(state),
              _buildMyTasksTab(state),
              _buildOverdueTasksTab(state),
            ],
          );
        },
      ),
      floatingActionButton: PermissionWidget(
        requiredRole: UserRole.roommateAdmin,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CreateTaskPage(),
              ),
            );
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAllTasksTab(TaskState state) {
    if (state is TaskLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state is TasksLoaded) {
      final filteredTasks = _filterTasks(state.tasks);
      return _buildTaskList(filteredTasks);
    }
    
    return const Center(
      child: Text('No tasks available'),
    );
  }

  Widget _buildMyTasksTab(TaskState state) {
    // TODO: Get current user ID from context
    const currentUserId = 'current_user';
    
    if (state is TasksLoaded) {
      final myTasks = state.tasks
          .where((task) => task.assignedTo == currentUserId)
          .toList();
      final filteredTasks = _filterTasks(myTasks);
      return _buildTaskList(filteredTasks);
    }
    
    return const Center(
      child: Text('No tasks assigned to you'),
    );
  }

  Widget _buildOverdueTasksTab(TaskState state) {
    if (state is TasksLoaded) {
      final now = DateTime.now();
      final overdueTasks = state.tasks
          .where((task) => 
              task.dueDate.isBefore(now) && 
              task.status != TaskStatus.completed)
          .toList();
      final filteredTasks = _filterTasks(overdueTasks);
      return _buildTaskList(filteredTasks, isOverdue: true);
    }
    
    return const Center(
      child: Text('No overdue tasks'),
    );
  }

  Widget _buildTaskList(List<Task> tasks, {bool isOverdue = false}) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOverdue ? Icons.check_circle : Icons.task_alt,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isOverdue ? 'No overdue tasks!' : 'No tasks found',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TaskCubit>().loadTasks();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _buildTaskCard(task, isOverdue);
        },
      ),
    );
  }

  Widget _buildTaskCard(Task task, bool isOverdue) {
    final now = DateTime.now();
    final isTaskOverdue = task.dueDate.isBefore(now) && task.status != TaskStatus.completed;
    final daysUntilDue = task.dueDate.difference(now).inDays;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isTaskOverdue ? Colors.red : Colors.transparent,
          width: isTaskOverdue ? 2 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: task.status == TaskStatus.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                _buildTaskStatusChip(task.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task.description,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Assigned to: ${task.assignedTo}', // TODO: Get user name
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: isTaskOverdue ? Colors.red : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDueDate(task.dueDate, daysUntilDue),
                  style: TextStyle(
                    color: isTaskOverdue ? Colors.red : Colors.grey[600],
                    fontWeight: isTaskOverdue ? FontWeight.bold : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.stars, size: 16, color: Colors.amber[600]),
                const SizedBox(width: 4),
                Text(
                  '${task.creditsReward} credits',
                  style: TextStyle(color: Colors.amber[600]),
                ),
                const Spacer(),
                _buildTaskTypeChip(task.type),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (task.status != TaskStatus.completed) ...[
                  TextButton.icon(
                    onPressed: () => _markAsCompleted(task),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Complete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                TextButton.icon(
                  onPressed: () => _showTaskDetails(task),
                  icon: const Icon(Icons.info, size: 16),
                  label: const Text('Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskStatusChip(TaskStatus status) {
    Color color;
    String label;
    
    switch (status) {
      case TaskStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case TaskStatus.inProgress:
        color = Colors.blue;
        label = 'In Progress';
        break;
      case TaskStatus.completed:
        color = Colors.green;
        label = 'Completed';
        break;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildTaskTypeChip(TaskType type) {
    return Chip(
      label: Text(
        _getTaskTypeLabel(type),
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  String _formatDueDate(DateTime dueDate, int daysUntilDue) {
    if (daysUntilDue < 0) {
      return 'Overdue by ${-daysUntilDue} days';
    } else if (daysUntilDue == 0) {
      return 'Due today';
    } else if (daysUntilDue == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in $daysUntilDue days';
    }
  }

  String _getTaskTypeLabel(TaskType type) {
    switch (type) {
      case TaskType.cleaning:
        return 'Cleaning';
      case TaskType.maintenance:
        return 'Maintenance';
      case TaskType.cooking:
        return 'Cooking';
      case TaskType.shopping:
        return 'Shopping';
      case TaskType.other:
        return 'Other';
    }
  }

  List<Task> _filterTasks(List<Task> tasks) {
    var filtered = tasks;
    
    if (_filterStatus != null) {
      filtered = filtered.where((task) => task.status == _filterStatus).toList();
    }
    
    if (_filterType != null) {
      filtered = filtered.where((task) => task.type == _filterType).toList();
    }
    
    return filtered;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<TaskStatus?>(
              value: _filterStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Statuses')),
                ...TaskStatus.values.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.toString().split('.').last),
                )),
              ],
              onChanged: (value) => setState(() => _filterStatus = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskType?>(
              value: _filterType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Types')),
                ...TaskType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(_getTaskTypeLabel(type)),
                )),
              ],
              onChanged: (value) => setState(() => _filterType = value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filterStatus = null;
                _filterType = null;
              });
              Navigator.of(context).pop();
              context.read<TaskCubit>().loadTasks();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TaskCubit>().loadTasks();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _markAsCompleted(Task task) {
    context.read<TaskCubit>().completeTask(task.id);
  }

  void _showTaskDetails(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${task.description}'),
            const SizedBox(height: 8),
            Text('Type: ${_getTaskTypeLabel(task.type)}'),
            const SizedBox(height: 8),
            Text('Status: ${task.status.toString().split('.').last}'),
            const SizedBox(height: 8),
            Text('Due: ${task.dueDate.toString().split('.')[0]}'),
            const SizedBox(height: 8),
            Text('Credits: ${task.creditsReward}'),
            const SizedBox(height: 8),
            Text('Created: ${task.createdAt.toString().split('.')[0]}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}