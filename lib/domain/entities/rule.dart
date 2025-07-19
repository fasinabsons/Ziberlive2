import 'package:equatable/equatable.dart';

enum RuleCategory {
  noise,
  cleanliness,
  guests,
  smoking,
  commonAreas,
  safety,
  other,
}

enum RuleSeverity {
  low,
  medium,
  high,
}

class Rule extends Equatable {
  final String id;
  final String title;
  final String description;
  final RuleCategory category;
  final RuleSeverity severity;
  final bool isActive;
  final String apartmentId;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Rule({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    required this.isActive,
    required this.apartmentId,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        severity,
        isActive,
        apartmentId,
        createdBy,
        createdAt,
        updatedAt,
      ];

  Rule copyWith({
    String? id,
    String? title,
    String? description,
    RuleCategory? category,
    RuleSeverity? severity,
    bool? isActive,
    String? apartmentId,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Rule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      isActive: isActive ?? this.isActive,
      apartmentId: apartmentId ?? this.apartmentId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'severity': severity.name,
      'isActive': isActive,
      'apartmentId': apartmentId,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Rule.fromJson(Map<String, dynamic> json) {
    return Rule(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: RuleCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => RuleCategory.other,
      ),
      severity: RuleSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => RuleSeverity.medium,
      ),
      isActive: json['isActive'] ?? true,
      apartmentId: json['apartmentId'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}