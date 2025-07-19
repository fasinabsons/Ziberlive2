import 'package:equatable/equatable.dart';

enum ViolationStatus { 
  pending, 
  underReview,
  resolved, 
  dismissed 
}

enum ViolationSeverity { 
  minor, 
  moderate, 
  major 
}

class ViolationReport extends Equatable {
  final String id;
  final String ruleId;
  final String? violatorId;
  final String? reportedBy;
  final String description;
  final ViolationSeverity severity;
  final ViolationStatus status;
  final bool isAnonymous;
  final String apartmentId;
  final DateTime reportedAt;
  final DateTime? resolvedAt;
  final String? resolution;
  final String? resolvedBy;
  final List<String>? evidenceUrls;

  const ViolationReport({
    required this.id,
    required this.ruleId,
    this.violatorId,
    this.reportedBy,
    required this.description,
    required this.severity,
    required this.status,
    required this.isAnonymous,
    required this.apartmentId,
    required this.reportedAt,
    this.resolvedAt,
    this.resolution,
    this.resolvedBy,
    this.evidenceUrls,
  });

  @override
  List<Object?> get props => [
        id,
        ruleId,
        violatorId,
        reportedBy,
        description,
        severity,
        status,
        isAnonymous,
        apartmentId,
        reportedAt,
        resolvedAt,
        resolution,
        resolvedBy,
        evidenceUrls,
      ];

  ViolationReport copyWith({
    String? id,
    String? ruleId,
    String? violatorId,
    String? reportedBy,
    String? description,
    ViolationSeverity? severity,
    ViolationStatus? status,
    bool? isAnonymous,
    String? apartmentId,
    DateTime? reportedAt,
    DateTime? resolvedAt,
    String? resolution,
    String? resolvedBy,
    List<String>? evidenceUrls,
  }) {
    return ViolationReport(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      violatorId: violatorId ?? this.violatorId,
      reportedBy: reportedBy ?? this.reportedBy,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      apartmentId: apartmentId ?? this.apartmentId,
      reportedAt: reportedAt ?? this.reportedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolution: resolution ?? this.resolution,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      evidenceUrls: evidenceUrls ?? this.evidenceUrls,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ruleId': ruleId,
      'violatorId': violatorId,
      'reportedBy': reportedBy,
      'description': description,
      'severity': severity.name,
      'status': status.name,
      'isAnonymous': isAnonymous,
      'apartmentId': apartmentId,
      'reportedAt': reportedAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolution': resolution,
      'resolvedBy': resolvedBy,
      'evidenceUrls': evidenceUrls,
    };
  }

  factory ViolationReport.fromJson(Map<String, dynamic> json) {
    return ViolationReport(
      id: json['id'],
      ruleId: json['ruleId'],
      violatorId: json['violatorId'],
      reportedBy: json['reportedBy'],
      description: json['description'],
      severity: ViolationSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => ViolationSeverity.minor,
      ),
      status: ViolationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ViolationStatus.pending,
      ),
      isAnonymous: json['isAnonymous'] ?? false,
      apartmentId: json['apartmentId'],
      reportedAt: DateTime.parse(json['reportedAt']),
      resolvedAt: json['resolvedAt'] != null 
          ? DateTime.parse(json['resolvedAt'])
          : null,
      resolution: json['resolution'],
      resolvedBy: json['resolvedBy'],
      evidenceUrls: json['evidenceUrls'] != null
          ? List<String>.from(json['evidenceUrls'])
          : null,
    );
  }
}