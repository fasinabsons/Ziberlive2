import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/violation_report.dart';
import 'rule_violation_state.dart';

class RuleViolationCubit extends Cubit<RuleViolationState> {
  final List<ViolationReport> _reports = [];

  RuleViolationCubit() : super(ViolationReportInitial());

  Future<void> loadViolationReports() async {
    emit(ViolationReportLoading());
    
    try {
      // TODO: Load from repository
      // For now, using mock data
      await Future.delayed(const Duration(milliseconds: 500));
      
      final mockReports = _generateMockReports();
      _reports.clear();
      _reports.addAll(mockReports);
      
      emit(ViolationReportsLoaded(List.from(_reports)));
    } catch (e) {
      emit(ViolationReportError('Failed to load violation reports: ${e.toString()}'));
    }
  }

  Future<void> submitViolationReport(ViolationReport report) async {
    try {
      // TODO: Save to repository
      await Future.delayed(const Duration(milliseconds: 300));
      
      _reports.add(report);
      
      emit(ViolationReportSubmitted(report));
      emit(ViolationReportsLoaded(List.from(_reports)));
    } catch (e) {
      emit(ViolationReportError('Failed to submit violation report: ${e.toString()}'));
    }
  }

  Future<void> resolveViolationReport(
    String reportId,
    ViolationStatus status,
    String resolution,
  ) async {
    try {
      final reportIndex = _reports.indexWhere((r) => r.id == reportId);
      if (reportIndex != -1) {
        _reports[reportIndex] = _reports[reportIndex].copyWith(
          status: status,
          resolution: resolution,
          resolvedAt: DateTime.now(),
          resolvedBy: 'current_admin', // TODO: Get current admin ID
        );
        
        emit(ViolationReportResolved(
          reportId: reportId,
          status: status,
          resolution: resolution,
        ));
        
        await Future.delayed(const Duration(milliseconds: 300));
        emit(ViolationReportsLoaded(List.from(_reports)));
      }
    } catch (e) {
      emit(ViolationReportError('Failed to resolve violation report: ${e.toString()}'));
    }
  }

  List<ViolationReport> _generateMockReports() {
    final now = DateTime.now();
    
    return [
      ViolationReport(
        id: '1',
        ruleId: 'quiet_hours',
        violatorId: 'user2',
        reportedBy: 'user1',
        description: 'Loud music playing at 11:30 PM, disturbing sleep',
        severity: ViolationSeverity.moderate,
        status: ViolationStatus.pending,
        isAnonymous: false,
        apartmentId: 'apt_001',
        reportedAt: now.subtract(const Duration(hours: 2)),
      ),
      ViolationReport(
        id: '2',
        ruleId: 'common_area',
        violatorId: null,
        reportedBy: null,
        description: 'Kitchen left messy with dirty dishes and food scraps',
        severity: ViolationSeverity.minor,
        status: ViolationStatus.pending,
        isAnonymous: true,
        apartmentId: 'apt_001',
        reportedAt: now.subtract(const Duration(hours: 6)),
      ),
      ViolationReport(
        id: '3',
        ruleId: 'guest_policy',
        violatorId: 'user3',
        reportedBy: 'user4',
        description: 'Guest stayed overnight without prior notification',
        severity: ViolationSeverity.moderate,
        status: ViolationStatus.resolved,
        isAnonymous: false,
        apartmentId: 'apt_001',
        reportedAt: now.subtract(const Duration(days: 2)),
        resolvedAt: now.subtract(const Duration(days: 1)),
        resolution: 'Discussed with resident, agreed to follow guest policy in future',
        resolvedBy: 'admin1',
      ),
      ViolationReport(
        id: '4',
        ruleId: 'smoking',
        violatorId: 'user2',
        reportedBy: 'user1',
        description: 'Smoking detected in common area, lingering smell',
        severity: ViolationSeverity.major,
        status: ViolationStatus.dismissed,
        isAnonymous: false,
        apartmentId: 'apt_001',
        reportedAt: now.subtract(const Duration(days: 3)),
        resolvedAt: now.subtract(const Duration(days: 2)),
        resolution: 'Investigation showed no evidence of smoking in common area',
        resolvedBy: 'admin1',
      ),
    ];
  }
}