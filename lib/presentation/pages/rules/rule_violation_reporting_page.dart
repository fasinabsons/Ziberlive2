import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/rule.dart';
import '../../../domain/entities/violation_report.dart';
import '../../../domain/entities/user.dart';
import '../../core/widgets/permission_widget.dart';
import 'cubit/rule_violation_cubit.dart';
import 'cubit/rule_violation_state.dart';
import 'widgets/violation_report_card.dart';

class RuleViolationReportingPage extends StatefulWidget {
  const RuleViolationReportingPage({Key? key}) : super(key: key);

  @override
  State<RuleViolationReportingPage> createState() => _RuleViolationReportingPageState();
}

class _RuleViolationReportingPageState extends State<RuleViolationReportingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<RuleViolationCubit>().loadViolationReports();
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
        title: const Text('Rule Violation Reports'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Pending', icon: Icon(Icons.pending)),
            Tab(text: 'Resolved', icon: Icon(Icons.check_circle)),
            Tab(text: 'My Reports', icon: Icon(Icons.person)),
          ],
        ),
      ),
      body: BlocConsumer<RuleViolationCubit, RuleViolationState>(
        listener: (context, state) {
          if (state is ViolationReportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ViolationReportSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Violation report submitted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ViolationReportResolved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Violation report resolved'),
                backgroundColor: Colors.blue,
              ),
            );
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildPendingTab(state),
              _buildResolvedTab(state),
              _buildMyReportsTab(state),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReportViolationDialog(),
        backgroundColor: Colors.red,
        icon: const Icon(Icons.report, color: Colors.white),
        label: const Text('Report Violation', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildPendingTab(RuleViolationState state) {
    if (state is ViolationReportLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ViolationReportsLoaded) {
      final pendingReports = state.reports
          .where((report) => report.status == ViolationStatus.pending)
          .toList();

      if (pendingReports.isEmpty) {
        return _buildEmptyState(
          'No pending reports',
          'All violation reports have been reviewed',
          Icons.check_circle,
          Colors.green,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pendingReports.length,
        itemBuilder: (context, index) {
          final report = pendingReports[index];
          return ViolationReportCard(
            report: report,
            onResolve: (resolution) => _resolveReport(report, resolution),
            onDismiss: () => _dismissReport(report),
            showActions: true,
          );
        },
      );
    }

    return _buildEmptyState(
      'Failed to load reports',
      'Please try again later',
      Icons.error,
      Colors.red,
    );
  }

  Widget _buildResolvedTab(RuleViolationState state) {
    if (state is ViolationReportsLoaded) {
      final resolvedReports = state.reports
          .where((report) => report.status != ViolationStatus.pending)
          .toList();

      if (resolvedReports.isEmpty) {
        return _buildEmptyState(
          'No resolved reports',
          'Resolved violation reports will appear here',
          Icons.history,
          Colors.grey,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: resolvedReports.length,
        itemBuilder: (context, index) {
          final report = resolvedReports[index];
          return ViolationReportCard(
            report: report,
            showActions: false,
          );
        },
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildMyReportsTab(RuleViolationState state) {
    if (state is ViolationReportsLoaded) {
      const currentUserId = 'current_user'; // TODO: Get from context
      final myReports = state.reports
          .where((report) => report.reportedBy == currentUserId)
          .toList();

      if (myReports.isEmpty) {
        return _buildEmptyState(
          'No reports submitted',
          'Your violation reports will appear here',
          Icons.report,
          Colors.orange,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: myReports.length,
        itemBuilder: (context, index) {
          final report = myReports[index];
          return ViolationReportCard(
            report: report,
            showActions: false,
            isMyReport: true,
          );
        },
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon, Color color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: color.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showReportViolationDialog() {
    showDialog(
      context: context,
      builder: (context) => _ReportViolationDialog(
        onSubmit: (report) {
          context.read<RuleViolationCubit>().submitViolationReport(report);
        },
      ),
    );
  }

  void _resolveReport(ViolationReport report, String resolution) {
    context.read<RuleViolationCubit>().resolveViolationReport(
      report.id,
      ViolationStatus.resolved,
      resolution,
    );
  }

  void _dismissReport(ViolationReport report) {
    context.read<RuleViolationCubit>().resolveViolationReport(
      report.id,
      ViolationStatus.dismissed,
      'Report dismissed by admin',
    );
  }
}

class _ReportViolationDialog extends StatefulWidget {
  final Function(ViolationReport) onSubmit;

  const _ReportViolationDialog({required this.onSubmit});

  @override
  State<_ReportViolationDialog> createState() => _ReportViolationDialogState();
}

class _ReportViolationDialogState extends State<_ReportViolationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  
  String? _selectedRuleId;
  String? _selectedViolatorId;
  ViolationSeverity _severity = ViolationSeverity.minor;
  bool _isAnonymous = false;
  
  final List<Rule> _availableRules = []; // TODO: Load from repository
  final List<User> _availableUsers = []; // TODO: Load from repository

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // TODO: Load actual rules and users
    // For now using mock data
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.report, color: Colors.red),
          const SizedBox(width: 8),
          const Text('Report Rule Violation'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rule selection
              DropdownButtonFormField<String>(
                value: _selectedRuleId,
                decoration: const InputDecoration(
                  labelText: 'Which rule was violated?',
                  border: OutlineInputBorder(),
                ),
                items: _getMockRules().map((rule) {
                  return DropdownMenuItem(
                    value: rule['id'],
                    child: Text(rule['name']),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedRuleId = value),
                validator: (value) => value == null ? 'Please select a rule' : null,
              ),
              
              const SizedBox(height: 16),
              
              // Violator selection (optional for anonymous reports)
              if (!_isAnonymous) ...[
                DropdownButtonFormField<String>(
                  value: _selectedViolatorId,
                  decoration: const InputDecoration(
                    labelText: 'Who violated the rule? (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: _getMockUsers().map((user) {
                    return DropdownMenuItem(
                      value: user['id'],
                      child: Text(user['name']),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedViolatorId = value),
                ),
                const SizedBox(height: 16),
              ],
              
              // Anonymous reporting toggle
              SwitchListTile(
                title: const Text('Report anonymously'),
                subtitle: const Text('Your identity will be hidden'),
                value: _isAnonymous,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value;
                    if (value) _selectedViolatorId = null;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Severity selection
              const Text('Severity Level:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Column(
                children: ViolationSeverity.values.map((severity) {
                  return RadioListTile<ViolationSeverity>(
                    title: Text(_getSeverityLabel(severity)),
                    subtitle: Text(_getSeverityDescription(severity)),
                    value: severity,
                    groupValue: _severity,
                    onChanged: (value) => setState(() => _severity = value!),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe what happened...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a description';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Warning message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please ensure your report is accurate and made in good faith. False reports may result in consequences.',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Submit Report'),
        ),
      ],
    );
  }

  List<Map<String, String>> _getMockRules() {
    return [
      {'id': 'quiet_hours', 'name': 'Quiet Hours (10 PM - 6 AM)'},
      {'id': 'common_area', 'name': 'Common Area Cleanliness'},
      {'id': 'guest_policy', 'name': 'Guest Policy'},
      {'id': 'smoking', 'name': 'No Smoking Policy'},
      {'id': 'noise_level', 'name': 'Noise Level Guidelines'},
    ];
  }

  List<Map<String, String>> _getMockUsers() {
    return [
      {'id': 'user1', 'name': 'Alice Johnson'},
      {'id': 'user2', 'name': 'Bob Smith'},
      {'id': 'user3', 'name': 'Carol Davis'},
      {'id': 'user4', 'name': 'David Wilson'},
    ];
  }

  String _getSeverityLabel(ViolationSeverity severity) {
    switch (severity) {
      case ViolationSeverity.minor:
        return 'Minor';
      case ViolationSeverity.moderate:
        return 'Moderate';
      case ViolationSeverity.major:
        return 'Major';
    }
  }

  String _getSeverityDescription(ViolationSeverity severity) {
    switch (severity) {
      case ViolationSeverity.minor:
        return 'Small issue, gentle reminder needed';
      case ViolationSeverity.moderate:
        return 'Noticeable problem, discussion required';
      case ViolationSeverity.major:
        return 'Serious violation, immediate action needed';
    }
  }

  void _submitReport() {
    if (!_formKey.currentState!.validate()) return;

    final report = ViolationReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ruleId: _selectedRuleId!,
      violatorId: _selectedViolatorId,
      reportedBy: _isAnonymous ? null : 'current_user', // TODO: Get current user ID
      description: _descriptionController.text.trim(),
      severity: _severity,
      status: ViolationStatus.pending,
      isAnonymous: _isAnonymous,
      reportedAt: DateTime.now(),
    );

    widget.onSubmit(report);
    Navigator.of(context).pop();
  }
}

