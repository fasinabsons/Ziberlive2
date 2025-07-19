import 'package:equatable/equatable.dart';
import '../../../../domain/entities/violation_report.dart';

abstract class RuleViolationState extends Equatable {
  const RuleViolationState();

  @override
  List<Object?> get props => [];
}

class ViolationReportInitial extends RuleViolationState {}

class ViolationReportLoading extends RuleViolationState {}

class ViolationReportsLoaded extends RuleViolationState {
  final List<ViolationReport> reports;

  const ViolationReportsLoaded(this.reports);

  @override
  List<Object?> get props => [reports];
}

class ViolationReportSubmitted extends RuleViolationState {
  final ViolationReport report;

  const ViolationReportSubmitted(this.report);

  @override
  List<Object?> get props => [report];
}

class ViolationReportResolved extends RuleViolationState {
  final String reportId;
  final ViolationStatus status;
  final String resolution;

  const ViolationReportResolved({
    required this.reportId,
    required this.status,
    required this.resolution,
  });

  @override
  List<Object?> get props => [reportId, status, resolution];
}

class ViolationReportError extends RuleViolationState {
  final String message;

  const ViolationReportError(this.message);

  @override
  List<Object?> get props => [message];
}