import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../domain/entities/schedule.dart';
import '../../../domain/entities/task.dart';

class ScheduleCalendarView extends StatefulWidget {
  final List<Schedule> schedules;
  final List<Task>? tasks;

  const ScheduleCalendarView({
    Key? key,
    required this.schedules,
    this.tasks,
  }) : super(key: key);

  @override
  State<ScheduleCalendarView> createState() => _ScheduleCalendarViewState();
}

class _ScheduleCalendarViewState extends State<ScheduleCalendarView> {
  late final ValueNotifier<List<CalendarEvent>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    final events = <CalendarEvent>[];
    
    // Add schedule slots for the day
    for (final schedule in widget.schedules) {
      for (final slot in schedule.slots) {
        if (isSameDay(slot.startTime, day)) {
          events.add(CalendarEvent(
            id: slot.id,
            title: slot.description ?? schedule.name,
            startTime: slot.startTime,
            endTime: slot.endTime,
            type: CalendarEventType.schedule,
            isCompleted: slot.isCompleted,
            assignedUserId: slot.assignedUserId,
            scheduleType: schedule.type,
          ));
        }
      }
    }
    
    // Add tasks for the day
    if (widget.tasks != null) {
      for (final task in widget.tasks!) {
        if (isSameDay(task.dueDate, day)) {
          events.add(CalendarEvent(
            id: task.id,
            title: task.name,
            startTime: task.dueDate,
            endTime: task.dueDate.add(const Duration(hours: 1)),
            type: CalendarEventType.task,
            isCompleted: task.status == TaskStatus.completed,
            assignedUserId: task.assignedTo,
            taskType: task.type,
          ));
        }
      }
    }
    
    // Sort events by start time
    events.sort((a, b) => a.startTime.compareTo(b.startTime));
    
    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<CalendarEvent>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          eventLoader: _getEventsForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: TextStyle(color: Colors.red[400]),
            holidayTextStyle: TextStyle(color: Colors.red[400]),
            markerDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
            formatButtonDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12.0),
            ),
            formatButtonTextStyle: const TextStyle(
              color: Colors.white,
            ),
          ),
          onDaySelected: _onDaySelected,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ValueListenableBuilder<List<CalendarEvent>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return _buildEventCard(value[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    final isOverdue = event.startTime.isBefore(DateTime.now()) && !event.isCompleted;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isOverdue ? Colors.red : 
                 event.isCompleted ? Colors.green : Colors.transparent,
          width: isOverdue || event.isCompleted ? 2 : 0,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getEventColor(event),
          child: Icon(
            _getEventIcon(event),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          event.title,
          style: TextStyle(
            decoration: event.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
              style: const TextStyle(fontSize: 12),
            ),
            if (event.assignedUserId.isNotEmpty)
              Text(
                'Assigned to: ${event.assignedUserId}', // TODO: Get user name
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!event.isCompleted && event.type == CalendarEventType.schedule)
              IconButton(
                onPressed: () => _showSwapDialog(event),
                icon: const Icon(Icons.swap_horiz),
                tooltip: 'Swap slot',
              ),
            if (!event.isCompleted)
              IconButton(
                onPressed: () => _markAsCompleted(event),
                icon: const Icon(Icons.check_circle_outline),
                color: Colors.green,
                tooltip: 'Mark as completed',
              ),
          ],
        ),
        onTap: () => _showEventDetails(event),
      ),
    );
  }

  Color _getEventColor(CalendarEvent event) {
    if (event.isCompleted) return Colors.green;
    
    switch (event.type) {
      case CalendarEventType.schedule:
        switch (event.scheduleType) {
          case ScheduleType.cleaning:
            return Colors.blue;
          case ScheduleType.cooking:
            return Colors.orange;
          case ScheduleType.communityCooking:
            return Colors.purple;
          case ScheduleType.maintenance:
            return Colors.brown;
          default:
            return Colors.grey;
        }
      case CalendarEventType.task:
        switch (event.taskType) {
          case TaskType.cleaning:
            return Colors.blue;
          case TaskType.cooking:
            return Colors.orange;
          case TaskType.maintenance:
            return Colors.brown;
          case TaskType.shopping:
            return Colors.green;
          case TaskType.other:
            return Colors.grey;
          default:
            return Colors.grey;
        }
    }
  }

  IconData _getEventIcon(CalendarEvent event) {
    if (event.isCompleted) return Icons.check;
    
    switch (event.type) {
      case CalendarEventType.schedule:
        return Icons.schedule;
      case CalendarEventType.task:
        return Icons.task_alt;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _showSwapDialog(CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => SwapSlotDialog(
        currentEvent: event,
        availableSlots: _getAvailableSlotsForSwap(event),
        onSwap: (targetSlotId) {
          _swapSlots(event.id, targetSlotId);
        },
      ),
    );
  }

  List<CalendarEvent> _getAvailableSlotsForSwap(CalendarEvent currentEvent) {
    final availableSlots = <CalendarEvent>[];
    
    // Get all schedule slots that can be swapped
    for (final schedule in widget.schedules) {
      for (final slot in schedule.slots) {
        if (slot.id != currentEvent.id && 
            !slot.isCompleted && 
            slot.assignedUserId != currentEvent.assignedUserId) {
          availableSlots.add(CalendarEvent(
            id: slot.id,
            title: slot.description ?? schedule.name,
            startTime: slot.startTime,
            endTime: slot.endTime,
            type: CalendarEventType.schedule,
            isCompleted: slot.isCompleted,
            assignedUserId: slot.assignedUserId,
            scheduleType: schedule.type,
          ));
        }
      }
    }
    
    return availableSlots;
  }

  void _swapSlots(String slotId1, String slotId2) {
    // TODO: Implement slot swapping logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Slot swap requested - pending approval'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _markAsCompleted(CalendarEvent event) {
    // TODO: Implement completion logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${event.title} marked as completed!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showEventDetails(CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${event.type.toString().split('.').last}'),
            const SizedBox(height: 8),
            Text('Time: ${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}'),
            const SizedBox(height: 8),
            Text('Assigned to: ${event.assignedUserId}'),
            const SizedBox(height: 8),
            Text('Status: ${event.isCompleted ? "Completed" : "Pending"}'),
            if (event.scheduleType != null) ...[
              const SizedBox(height: 8),
              Text('Schedule Type: ${event.scheduleType.toString().split('.').last}'),
            ],
            if (event.taskType != null) ...[
              const SizedBox(height: 8),
              Text('Task Type: ${event.taskType.toString().split('.').last}'),
            ],
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

class SwapSlotDialog extends StatefulWidget {
  final CalendarEvent currentEvent;
  final List<CalendarEvent> availableSlots;
  final Function(String) onSwap;

  const SwapSlotDialog({
    Key? key,
    required this.currentEvent,
    required this.availableSlots,
    required this.onSwap,
  }) : super(key: key);

  @override
  State<SwapSlotDialog> createState() => _SwapSlotDialogState();
}

class _SwapSlotDialogState extends State<SwapSlotDialog> {
  String? _selectedSlotId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Swap Schedule Slot'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current: ${widget.currentEvent.title}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Select slot to swap with:'),
            const SizedBox(height: 8),
            if (widget.availableSlots.isEmpty)
              const Text(
                'No available slots for swapping',
                style: TextStyle(color: Colors.grey),
              )
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: widget.availableSlots.length,
                  itemBuilder: (context, index) {
                    final slot = widget.availableSlots[index];
                    return RadioListTile<String>(
                      title: Text(slot.title),
                      subtitle: Text(
                        '${slot.startTime.day}/${slot.startTime.month} ${slot.startTime.hour.toString().padLeft(2, '0')}:${slot.startTime.minute.toString().padLeft(2, '0')} - ${slot.assignedUserId}',
                      ),
                      value: slot.id,
                      groupValue: _selectedSlotId,
                      onChanged: (value) {
                        setState(() {
                          _selectedSlotId = value;
                        });
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _selectedSlotId != null
              ? () {
                  widget.onSwap(_selectedSlotId!);
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text('Swap'),
        ),
      ],
    );
  }
}

enum CalendarEventType { schedule, task }

class CalendarEvent {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final CalendarEventType type;
  final bool isCompleted;
  final String assignedUserId;
  final ScheduleType? scheduleType;
  final TaskType? taskType;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.isCompleted,
    required this.assignedUserId,
    this.scheduleType,
    this.taskType,
  });
}