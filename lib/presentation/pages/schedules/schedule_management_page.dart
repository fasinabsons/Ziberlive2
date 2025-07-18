import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/schedule.dart';
import '../../../domain/entities/user.dart';
import '../../core/widgets/permission_widget.dart';
import 'cubit/schedule_cubit.dart';
import 'cubit/schedule_state.dart';
import 'create_schedule_page.dart';
import 'schedule_calendar_view.dart';

class ScheduleManagementPage extends StatefulWidget {
  const ScheduleManagementPage({Key? key}) : super(key: key);

  @override
  State<ScheduleManagementPage> createState() => _ScheduleManagementPageState();
}

class _ScheduleManagementPageState extends State<ScheduleManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ScheduleType? _filterType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<ScheduleCubit>().loadSchedules();
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
        title: const Text('Schedule Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Schedules', icon: Icon(Icons.schedule)),
            Tab(text: 'Calendar', icon: Icon(Icons.calendar_month)),
            Tab(text: 'My Slots', icon: Icon(Icons.person_pin_circle)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: () => context.read<ScheduleCubit>().loadSchedules(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocConsumer<ScheduleCubit, ScheduleState>(
        listener: (context, state) {
          if (state is ScheduleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ScheduleUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Schedule updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<ScheduleCubit>().loadSchedules();
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildSchedulesTab(state),
              _buildCalendarTab(state),
              _buildMySlotsTab(state),
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
                builder: (context) => const CreateSchedulePage(),
              ),
            );
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSchedulesTab(ScheduleState state) {
    if (state is ScheduleLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state is SchedulesLoaded) {
      final filteredSchedules = _filterSchedules(state.schedules);
      return _buildScheduleList(filteredSchedules);
    }
    
    return const Center(
      child: Text('No schedules available'),
    );
  }

  Widget _buildCalendarTab(ScheduleState state) {
    if (state is SchedulesLoaded) {
      return ScheduleCalendarView(schedules: state.schedules);
    }
    
    return const Center(
      child: Text('No schedule data available'),
    );
  }

  Widget _buildMySlotsTab(ScheduleState state) {
    // TODO: Get current user ID from context
    const currentUserId = 'current_user';
    
    if (state is SchedulesLoaded) {
      final mySlots = <ScheduleSlot>[];
      for (final schedule in state.schedules) {
        mySlots.addAll(
          schedule.slots.where((slot) => slot.assignedUserId == currentUserId),
        );
      }
      
      // Sort by start time
      mySlots.sort((a, b) => a.startTime.compareTo(b.startTime));
      
      return _buildSlotList(mySlots);
    }
    
    return const Center(
      child: Text('No slots assigned to you'),
    );
  }

  Widget _buildScheduleList(List<Schedule> schedules) {
    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No schedules found',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ScheduleCubit>().loadSchedules();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];
          return _buildScheduleCard(schedule);
        },
      ),
    );
  }

  Widget _buildScheduleCard(Schedule schedule) {
    final now = DateTime.now();
    final isActive = schedule.isActive && 
        (schedule.endDate == null || schedule.endDate!.isAfter(now));
    final completedSlots = schedule.slots.where((slot) => slot.isCompleted).length;
    final totalSlots = schedule.slots.length;
    final completionRate = totalSlots > 0 ? completedSlots / totalSlots : 0.0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive ? Colors.green : Colors.grey,
          width: 1,
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
                    schedule.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildScheduleStatusChip(isActive),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _getScheduleTypeLabel(schedule.type),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.refresh, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _getRotationPatternLabel(schedule.rotationPattern),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.date_range, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Started: ${_formatDate(schedule.startDate)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (schedule.endDate != null) ...[
                  const SizedBox(width: 16),
                  Text(
                    'Ends: ${_formatDate(schedule.endDate!)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress: $completedSlots/$totalSlots slots completed',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: completionRate,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          completionRate > 0.8 ? Colors.green : 
                          completionRate > 0.5 ? Colors.orange : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${schedule.slots.length} slots',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _rotateAssignments(schedule),
                  icon: const Icon(Icons.rotate_right, size: 16),
                  label: const Text('Rotate'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showScheduleDetails(schedule),
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

  Widget _buildSlotList(List<ScheduleSlot> slots) {
    if (slots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_pin_circle,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No slots assigned to you',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        return _buildSlotCard(slot);
      },
    );
  }

  Widget _buildSlotCard(ScheduleSlot slot) {
    final now = DateTime.now();
    final isUpcoming = slot.startTime.isAfter(now);
    final isOverdue = slot.endTime.isBefore(now) && !slot.isCompleted;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isOverdue ? Colors.red : 
                 slot.isCompleted ? Colors.green : Colors.transparent,
          width: isOverdue || slot.isCompleted ? 2 : 0,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: slot.isCompleted ? Colors.green : 
                          isOverdue ? Colors.red : Colors.blue,
          child: Icon(
            slot.isCompleted ? Icons.check : 
            isOverdue ? Icons.warning : Icons.schedule,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          slot.description ?? 'Schedule Slot',
          style: TextStyle(
            decoration: slot.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_formatDateTime(slot.startTime)} - ${_formatDateTime(slot.endTime)}'),
            if (slot.creditsAwarded != null)
              Text('Credits: ${slot.creditsAwarded}'),
          ],
        ),
        trailing: slot.isCompleted ? null : 
                 IconButton(
                   onPressed: () => _completeSlot(slot),
                   icon: const Icon(Icons.check_circle_outline),
                   color: Colors.green,
                 ),
      ),
    );
  }

  Widget _buildScheduleStatusChip(bool isActive) {
    return Chip(
      label: Text(
        isActive ? 'Active' : 'Inactive',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: isActive ? Colors.green : Colors.grey,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  List<Schedule> _filterSchedules(List<Schedule> schedules) {
    if (_filterType == null) return schedules;
    return schedules.where((schedule) => schedule.type == _filterType).toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Schedules'),
        content: DropdownButtonFormField<ScheduleType?>(
          value: _filterType,
          decoration: const InputDecoration(labelText: 'Type'),
          items: [
            const DropdownMenuItem(value: null, child: Text('All Types')),
            ...ScheduleType.values.map((type) => DropdownMenuItem(
              value: type,
              child: Text(_getScheduleTypeLabel(type)),
            )),
          ],
          onChanged: (value) => setState(() => _filterType = value),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _filterType = null);
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _rotateAssignments(Schedule schedule) {
    context.read<ScheduleCubit>().rotateAssignments(schedule.id);
  }

  void _completeSlot(ScheduleSlot slot) {
    context.read<ScheduleCubit>().completeSlot(slot.id, 'current_user');
  }

  void _showScheduleDetails(Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(schedule.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type: ${_getScheduleTypeLabel(schedule.type)}'),
              const SizedBox(height: 8),
              Text('Rotation: ${_getRotationPatternLabel(schedule.rotationPattern)}'),
              const SizedBox(height: 8),
              Text('Start Date: ${_formatDate(schedule.startDate)}'),
              if (schedule.endDate != null) ...[
                const SizedBox(height: 8),
                Text('End Date: ${_formatDate(schedule.endDate!)}'),
              ],
              const SizedBox(height: 8),
              Text('Status: ${schedule.isActive ? "Active" : "Inactive"}'),
              const SizedBox(height: 16),
              const Text('Slots:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...schedule.slots.map((slot) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text(
                  '• ${slot.description ?? "Slot"} - ${_formatDateTime(slot.startTime)}',
                  style: const TextStyle(fontSize: 12),
                ),
              )),
            ],
          ),
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