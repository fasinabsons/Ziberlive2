import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/permission_widget.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/task.dart';
import 'cubit/task_cubit.dart';
import 'cubit/task_state.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({Key? key}) : super(key: key);

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _selectedDueDate;
  String? _selectedAssigneeId;
  TaskType _selectedTaskType = TaskType.cleaning;
  int _creditsReward = 5;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<TaskCubit, TaskState>(
        listener: (context, state) {
          if (state is TaskCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return PermissionWidget(
            requiredRole: UserRole.roommateAdmin,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTaskNameField(),
                    const SizedBox(height: 16),
                    _buildDescriptionField(),
                    const SizedBox(height: 16),
                    _buildTaskTypeSelector(),
                    const SizedBox(height: 16),
                    _buildAssigneeSelector(state),
                    const SizedBox(height: 16),
                    _buildDueDateSelector(),
                    const SizedBox(height: 16),
                    _buildCreditsRewardField(),
                    const SizedBox(height: 24),
                    _buildCreateButton(state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Task Name',
        hintText: 'e.g., Clean Kitchen',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.task_alt),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a task name';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'Detailed task description...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.description),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a task description';
        }
        return null;
      },
    );
  }

  Widget _buildTaskTypeSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: TaskType.values.map((type) {
                return ChoiceChip(
                  label: Text(_getTaskTypeLabel(type)),
                  selected: _selectedTaskType == type,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedTaskType = type;
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssigneeSelector(TaskState state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assign To',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (state is TaskLoading)
              const Center(child: CircularProgressIndicator())
            else if (state is TaskUsersLoaded)
              DropdownButtonFormField<String>(
                value: _selectedAssigneeId,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                hint: const Text('Select user to assign'),
                items: state.users.map((user) {
                  return DropdownMenuItem<String>(
                    value: user.id,
                    child: Text(user.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAssigneeId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a user to assign';
                  }
                  return null;
                },
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  context.read<TaskCubit>().loadUsers();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Load Users'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDueDateSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: const Text('Due Date'),
        subtitle: Text(
          _selectedDueDate != null
              ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
              : 'Select due date',
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: _selectDueDate,
      ),
    );
  }

  Widget _buildCreditsRewardField() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Credits Reward',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _creditsReward.toDouble(),
                    min: 1,
                    max: 20,
                    divisions: 19,
                    label: '$_creditsReward credits',
                    onChanged: (value) {
                      setState(() {
                        _creditsReward = value.round();
                      });
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_creditsReward',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton(TaskState state) {
    return ElevatedButton(
      onPressed: state is TaskLoading ? null : _createTask,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: state is TaskLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Create Task',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      
      if (timePicked != null) {
        setState(() {
          _selectedDueDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            timePicked.hour,
            timePicked.minute,
          );
        });
      }
    }
  }

  void _createTask() {
    if (_formKey.currentState!.validate() && _selectedDueDate != null) {
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        apartmentId: 'current_apartment', // TODO: Get from user context
        assignedTo: _selectedAssigneeId!,
        createdBy: 'current_user', // TODO: Get from user context
        dueDate: _selectedDueDate!,
        status: TaskStatus.pending,
        creditsReward: _creditsReward,
        type: _selectedTaskType,
        createdAt: DateTime.now(),
      );

      context.read<TaskCubit>().createTask(task);
    } else if (_selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a due date'),
          backgroundColor: Colors.orange,
        ),
      );
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
}