import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/investment_group.dart';
import '../../../domain/entities/user.dart';
import '../../core/widgets/permission_widget.dart';

class InvestmentMeetingPage extends StatefulWidget {
  final InvestmentGroup group;

  const InvestmentMeetingPage({
    Key? key,
    required this.group,
  }) : super(key: key);

  @override
  State<InvestmentMeetingPage> createState() => _InvestmentMeetingPageState();
}

class _InvestmentMeetingPageState extends State<InvestmentMeetingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: Text('${widget.group.name} - Meetings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Upcoming', icon: Icon(Icons.schedule)),
            Tab(text: 'Proposals', icon: Icon(Icons.pending_actions)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcomingMeetingsTab(),
          _buildProposalsTab(),
          _buildMeetingHistoryTab(),
        ],
      ),
      floatingActionButton: PermissionWidget(
        requiredRole: UserRole.roommateAdmin,
        child: FloatingActionButton(
          onPressed: () => _showScheduleMeetingDialog(),
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildUpcomingMeetingsTab() {
    // Mock data for upcoming meetings
    final upcomingMeetings = [
      InvestmentMeeting(
        id: '1',
        groupId: widget.group.id,
        title: 'Monthly Investment Review',
        description: 'Review current portfolio performance and discuss new opportunities',
        scheduledDate: DateTime.now().add(const Duration(days: 3)),
        duration: const Duration(hours: 1),
        location: 'Apartment Common Area',
        organizer: 'current_user',
        attendees: widget.group.participantIds,
        agenda: [
          'Portfolio performance review',
          'New investment proposals',
          'Risk assessment',
          'Next month planning',
        ],
        status: MeetingStatus.scheduled,
      ),
      InvestmentMeeting(
        id: '2',
        groupId: widget.group.id,
        title: 'Q1 Strategy Planning',
        description: 'Plan investment strategy for the next quarter',
        scheduledDate: DateTime.now().add(const Duration(days: 10)),
        duration: const Duration(hours: 2),
        location: 'Virtual Meeting',
        organizer: 'current_user',
        attendees: widget.group.participantIds,
        agenda: [
          'Q4 performance analysis',
          'Market outlook discussion',
          'Goal setting for Q1',
          'Budget allocation',
        ],
        status: MeetingStatus.scheduled,
      ),
    ];

    return _buildMeetingList(upcomingMeetings, isUpcoming: true);
  }

  Widget _buildProposalsTab() {
    final pendingProposals = widget.group.investments
        .where((investment) => investment.status == InvestmentStatus.proposed)
        .toList();

    if (pendingProposals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pending_actions,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No pending proposals',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Investment proposals will appear here for group voting',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingProposals.length,
      itemBuilder: (context, index) {
        final proposal = pendingProposals[index];
        return _buildProposalCard(proposal);
      },
    );
  }

  Widget _buildMeetingHistoryTab() {
    // Mock data for meeting history
    final pastMeetings = [
      InvestmentMeeting(
        id: '3',
        groupId: widget.group.id,
        title: 'Initial Group Formation',
        description: 'First meeting to establish investment group and set goals',
        scheduledDate: DateTime.now().subtract(const Duration(days: 30)),
        duration: const Duration(hours: 1, minutes: 30),
        location: 'Apartment Common Area',
        organizer: 'current_user',
        attendees: widget.group.participantIds,
        agenda: [
          'Group formation',
          'Investment goals discussion',
          'Risk tolerance assessment',
          'Initial contribution planning',
        ],
        status: MeetingStatus.completed,
        notes: 'Successfully formed investment group with \$${widget.group.totalContributions.toStringAsFixed(0)} initial pool.',
      ),
    ];

    return _buildMeetingList(pastMeetings, isUpcoming: false);
  }

  Widget _buildMeetingList(List<InvestmentMeeting> meetings, {required bool isUpcoming}) {
    if (meetings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming ? Icons.schedule : Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? 'No upcoming meetings' : 'No meeting history',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            if (isUpcoming) ...[
              const SizedBox(height: 8),
              Text(
                'Schedule a meeting to discuss investments with your group',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Refresh meetings
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: meetings.length,
        itemBuilder: (context, index) {
          final meeting = meetings[index];
          return _buildMeetingCard(meeting, isUpcoming);
        },
      ),
    );
  }

  Widget _buildMeetingCard(InvestmentMeeting meeting, bool isUpcoming) {
    final now = DateTime.now();
    final isToday = meeting.scheduledDate.day == now.day &&
        meeting.scheduledDate.month == now.month &&
        meeting.scheduledDate.year == now.year;
    final daysUntil = meeting.scheduledDate.difference(now).inDays;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isToday ? Colors.orange : Colors.transparent,
          width: isToday ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: () => _showMeetingDetails(meeting),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      meeting.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildMeetingStatusChip(meeting.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                meeting.description,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatMeetingDateTime(meeting.scheduledDate, meeting.duration),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    meeting.location,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${meeting.attendees.length} attendees',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              if (isUpcoming && isToday) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.today, color: Colors.orange[700], size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Meeting is today!',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (isUpcoming && daysUntil > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.blue[700], size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'In $daysUntil day${daysUntil > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProposalCard(Investment proposal) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                    proposal.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Pending Vote',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              proposal.description,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildProposalStat(
                    'Amount',
                    '\$${proposal.amount.toStringAsFixed(0)}',
                    Icons.attach_money,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProposalStat(
                    'Expected Return',
                    '${proposal.expectedReturn.toStringAsFixed(1)}%',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectProposal(proposal),
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text('Reject', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveProposal(proposal),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
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

  Widget _buildProposalStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingStatusChip(MeetingStatus status) {
    Color color;
    String label;
    
    switch (status) {
      case MeetingStatus.scheduled:
        color = Colors.blue;
        label = 'Scheduled';
        break;
      case MeetingStatus.inProgress:
        color = Colors.orange;
        label = 'In Progress';
        break;
      case MeetingStatus.completed:
        color = Colors.green;
        label = 'Completed';
        break;
      case MeetingStatus.cancelled:
        color = Colors.red;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  String _formatMeetingDateTime(DateTime dateTime, Duration duration) {
    final endTime = dateTime.add(duration);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }

  void _showScheduleMeetingDialog() {
    showDialog(
      context: context,
      builder: (context) => _ScheduleMeetingDialog(groupId: widget.group.id),
    );
  }

  void _showMeetingDetails(InvestmentMeeting meeting) {
    showDialog(
      context: context,
      builder: (context) => _MeetingDetailsDialog(meeting: meeting),
    );
  }

  void _approveProposal(Investment proposal) {
    // TODO: Implement proposal approval
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Approved proposal: ${proposal.name}')),
    );
  }

  void _rejectProposal(Investment proposal) {
    // TODO: Implement proposal rejection
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rejected proposal: ${proposal.name}')),
    );
  }
}

// Supporting classes and dialogs
enum MeetingStatus { scheduled, inProgress, completed, cancelled }

class InvestmentMeeting {
  final String id;
  final String groupId;
  final String title;
  final String description;
  final DateTime scheduledDate;
  final Duration duration;
  final String location;
  final String organizer;
  final List<String> attendees;
  final List<String> agenda;
  final MeetingStatus status;
  final String? notes;

  InvestmentMeeting({
    required this.id,
    required this.groupId,
    required this.title,
    required this.description,
    required this.scheduledDate,
    required this.duration,
    required this.location,
    required this.organizer,
    required this.attendees,
    required this.agenda,
    required this.status,
    this.notes,
  });
}

class _ScheduleMeetingDialog extends StatefulWidget {
  final String groupId;

  const _ScheduleMeetingDialog({required this.groupId});

  @override
  State<_ScheduleMeetingDialog> createState() => _ScheduleMeetingDialogState();
}

class _ScheduleMeetingDialogState extends State<_ScheduleMeetingDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 19, minute: 0);
  Duration _duration = const Duration(hours: 1);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Schedule Meeting'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Meeting Title',
                hintText: 'Monthly Investment Review',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Discuss portfolio performance and new opportunities',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'Apartment Common Area',
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date'),
              subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
            ListTile(
              title: const Text('Time'),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Save meeting
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Meeting scheduled successfully!')),
            );
          },
          child: const Text('Schedule'),
        ),
      ],
    );
  }
}

class _MeetingDetailsDialog extends StatelessWidget {
  final InvestmentMeeting meeting;

  const _MeetingDetailsDialog({required this.meeting});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(meeting.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(meeting.description),
            const SizedBox(height: 16),
            Text('Date: ${meeting.scheduledDate.day}/${meeting.scheduledDate.month}/${meeting.scheduledDate.year}'),
            Text('Time: ${meeting.scheduledDate.hour.toString().padLeft(2, '0')}:${meeting.scheduledDate.minute.toString().padLeft(2, '0')}'),
            Text('Duration: ${meeting.duration.inHours}h ${meeting.duration.inMinutes % 60}m'),
            Text('Location: ${meeting.location}'),
            Text('Attendees: ${meeting.attendees.length}'),
            const SizedBox(height: 16),
            const Text('Agenda:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...meeting.agenda.map((item) => Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Text('• $item'),
            )),
            if (meeting.notes != null) ...[
              const SizedBox(height: 16),
              const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(meeting.notes!),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}