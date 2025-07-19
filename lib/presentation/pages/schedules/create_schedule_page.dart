import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/schedule.dart';
import '../../../domain/entities/user.dart';
import '../../core/widgets/permission_widget.dart';
import 'cubit/schedule_cubit.dart';

class CreateSchedulePage extends StatefulWidget {
  const CreateSchedulePage({Key? key}) : super(key: key);

  @override
  State<CreateSchedulePage> createState() => _CreateSchedulePageState();
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  ScheduleType _selectedType = ScheduleType.cleaning;
  RotationPattern _selectedRotation = RotationPattern.weekly;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _hasEndDate = false;
  
  final List<ScheduleSlotTemplate> _slotTemplates = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Schedule'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveSchedule,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildScheduleTypeSection(),
              const SizedBox(height: 24),
              _buildRotationSection(),
              const SizedBox(height: 24),
              _buildDateRangeSection(),
              const SizedBox(height: 24),
              _buildSlotsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Schedule Name',
                hintText: 'e.g., Weekly Kitchen Cleaning',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a schedule name';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTypeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schedule Type',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: ScheduleType.values.map((type) {
                return ChoiceChip(
                  label: Text(_getScheduleTypeLabel(type)),
                  selected: _selectedType == type,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedType = type);
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

  Widget _buildRotationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rotation Pattern',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Column(
              children: RotationPattern.values.map((pattern) {
                return RadioListTile<RotationPattern>(
                  title: Text(_getRotationPatternLabel(pattern)),
                  subtitle: Text(_getRotationPatternDescription(pattern)),
                  value: pattern,
                  groupValue: _selectedRotation,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedRotation = value);
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

  Widget _buildDateRangeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date Range',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Start Date'),
              subtitle: Text(_formatDate(_startDate)),
              onTap: () => _selectStartDate(),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Set End Date'),
              subtitle: const Text('Schedule will run indefinitely if not set'),
              value: _hasEndDate,
              onChanged: (value) {
                setState(() {
                  _hasEndDate = value;
                  if (!value) _endDate = null;
                });
              },
            ),
            if (_hasEndDate) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('End Date'),
                subtitle: Text(_endDate != null ? _formatDate(_endDate!) : 'Select end date'),
                onTap: () => _selectEndDate(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSlotsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Time Slots',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton.icon(
                  onPressed: _addSlotTemplate,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Slot'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_slotTemplates.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No time slots added yet',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add time slots to define when tasks should be performed',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _slotTemplates.length,
                itemBuilder: (context, index) {
                  final template = _slotTemplates[index];
                  return _buildSlotTemplateCard(template, index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotTemplateCard(ScheduleSlotTemplate template, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text('${index + 1}'),
        ),
        title: Text(template.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(template.description),
            const SizedBox(height: 4),
            Text(
              '${_getDayName(template.dayOfWeek)} at ${template.startTime} (${template.duration.inMinutes}min)',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${template.creditsReward} credits',
              style: TextStyle(
                color: Colors.amber[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () => _removeSlotTemplate(index),
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  String _getScheduleTypeLabel(ScheduleType type) {
    switch (type) {
      case ScheduleType.cleaning:
        return 'Cleaning';
      case ScheduleType.cooking:
        return 'Cooking';
      case ScheduleType.communityCooking:
        return 'Community Cooking';
      case ScheduleType.maintenance:
        return 'Maintenance';
    }
  }

  String _getRotationPatternLabel(RotationPattern pattern) {
    switch (pattern) {
      case RotationPattern.weekly:
        return 'Weekly';
      case RotationPattern.biweekly:
        return 'Bi-weekly';
      case RotationPattern.monthly:
        return 'Monthly';
    }
  }

  String _getRotationPatternDescription(RotationPattern pattern) {
    switch (pattern) {
      case RotationPattern.weekly:
        return 'Assignments rotate every week';
      case RotationPattern.biweekly:
        return 'Assignments rotate every two weeks';
      case RotationPattern.monthly:
        return 'Assignments rotate every month';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDayName(int dayOfWeek) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dayOfWeek - 1];
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  void _addSlotTemplate() {
    showDialog(
      context: context,
      builder: (context) => _SlotTemplateDialog(
        onSave: (template) {
          setState(() => _slotTemplates.add(template));
        },
      ),
    );
  }

  void _removeSlotTemplate(int index) {
    setState(() => _slotTemplates.removeAt(index));
  }

  void _saveSchedule() {
    if (!_formKey.currentState!.validate()) return;
    
    if (_slotTemplates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one time slot'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Create schedule slots from templates
    final slots = _slotTemplates.map((template) {
      final slotStartTime = _getNextSlotDateTime(template);
      return ScheduleSlot(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: slotStartTime,
        endTime: slotStartTime.add(template.duration),
        assignedUserId: 'user_1', // TODO: Implement proper user assignment
        description: template.description,
        creditsAwarded: template.creditsReward,
      );
    }).toList();

    final schedule = Schedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      type: _selectedType,
      apartmentId: 'apartment_1', // TODO: Get from context
      slots: slots,
      rotationPattern: _selectedRotation,
      startDate: _startDate,
      endDate: _endDate,
      createdBy: 'current_user', // TODO: Get from context
      createdAt: DateTime.now(),
    );

    context.read<ScheduleCubit>().createSchedule(schedule);
    Navigator.of(context).pop();
  }

  DateTime _getNextSlotDateTime(ScheduleSlotTemplate template) {
    // Calculate the next occurrence of the specified day and time
    final now = DateTime.now();
    var targetDate = _startDate;
    
    // Find the next occurrence of the specified day of week
    while (targetDate.weekday != template.dayOfWeek) {
      targetDate = targetDate.add(const Duration(days: 1));
    }
    
    // Set the time
    targetDate = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      template.startTime.hour,
      template.startTime.minute,
    );
    
    // If the calculated time is in the past, move to next week
    if (targetDate.isBefore(now)) {
      targetDate = targetDate.add(const Duration(days: 7));
    }
    
    return targetDate;
  }
}

class _SlotTemplateDialog extends StatefulWidget {
  final Function(ScheduleSlotTemplate) onSave;

  const _SlotTemplateDialog({required this.onSave});

  @override
  State<_SlotTemplateDialog> createState() => _SlotTemplateDialogState();
}

class _SlotTemplateDialogState extends State<_SlotTemplateDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _selectedDay = 1; // Monday
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  int _durationMinutes = 60;
  int _creditsReward = 5;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Time Slot'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Slot Name',
                hintText: 'e.g., Kitchen Cleaning',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g., Clean kitchen counters and sink',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedDay,
              decoration: const InputDecoration(labelText: 'Day of Week'),
              items: List.generate(7, (index) {
                final day = index + 1;
                return DropdownMenuItem(
                  value: day,
                  child: Text(_getDayName(day)),
                );
              }),
              onChanged: (value) => setState(() => _selectedDay = value!),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (time != null) {
                  setState(() => _selectedTime = time);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _durationMinutes,
              decoration: const InputDecoration(labelText: 'Duration'),
              items: [15, 30, 45, 60, 90, 120].map((minutes) {
                return DropdownMenuItem(
                  value: minutes,
                  child: Text('$minutes minutes'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _durationMinutes = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _creditsReward,
              decoration: const InputDecoration(labelText: 'Credits Reward'),
              items: [1, 2, 3, 5, 8, 10].map((credits) {
                return DropdownMenuItem(
                  value: credits,
                  child: Text('$credits credits'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _creditsReward = value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveSlotTemplate,
          child: const Text('Add'),
        ),
      ],
    );
  }

  String _getDayName(int dayOfWeek) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dayOfWeek - 1];
  }

  void _saveSlotTemplate() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a slot name')),
      );
      return;
    }

    final template = ScheduleSlotTemplate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      dayOfWeek: _selectedDay,
      startTime: TimeOfDay(hour: _selectedTime.hour, minute: _selectedTime.minute),
      duration: Duration(minutes: _durationMinutes),
      creditsReward: _creditsReward,
    );

    widget.onSave(template);
    Navigator.of(context).pop();
  }
}