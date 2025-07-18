import 'package:equatable/equatable.dart';

enum ScheduleType { cleaning, cooking, communityCooking, maintenance }

enum RotationPattern { weekly, biweekly, monthly }

enum RecurrenceType { none, daily, weekly, monthly }

class Schedule extends Equatable {
  final String id;
  final String name;
  final ScheduleType type;
  final String apartmentId;
  final List<ScheduleSlot> slots;
  final RotationPattern rotationPattern;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const Schedule({
    required this.id,
    required this.name,
    required this.type,
    required this.apartmentId,
    required this.slots,
    required this.rotationPattern,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    required this.createdBy,
    required this.createdAt,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        apartmentId,
        slots,
        rotationPattern,
        startDate,
        endDate,
        isActive,
        createdBy,
        createdAt,
        metadata,
      ];

  Schedule copyWith({
    String? id,
    String? name,
    ScheduleType? type,
    String? apartmentId,
    List<ScheduleSlot>? slots,
    RotationPattern? rotationPattern,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return Schedule(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      apartmentId: apartmentId ?? this.apartmentId,
      slots: slots ?? this.slots,
      rotationPattern: rotationPattern ?? this.rotationPattern,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'apartment_id': apartmentId,
      'slots_json': slots.map((slot) => slot.toJson()).toList(),
      'rotation_pattern': rotationPattern.toString().split('.').last,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'metadata_json': metadata != null ? metadata.toString() : null,
    };
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      name: json['name'],
      type: ScheduleType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      apartmentId: json['apartment_id'],
      slots: (json['slots_json'] as List)
          .map((slot) => ScheduleSlot.fromJson(slot))
          .toList(),
      rotationPattern: RotationPattern.values.firstWhere(
        (e) => e.toString().split('.').last == json['rotation_pattern'],
      ),
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      isActive: json['is_active'] == 1,
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      metadata: json['metadata_json'] != null 
          ? Map<String, dynamic>.from(json['metadata_json']) 
          : null,
    );
  }
}

class ScheduleSlot extends Equatable {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String assignedUserId;
  final String? description;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? completedBy;
  final int? creditsAwarded;

  const ScheduleSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.assignedUserId,
    this.description,
    this.isCompleted = false,
    this.completedAt,
    this.completedBy,
    this.creditsAwarded,
  });

  @override
  List<Object?> get props => [
        id,
        startTime,
        endTime,
        assignedUserId,
        description,
        isCompleted,
        completedAt,
        completedBy,
        creditsAwarded,
      ];

  ScheduleSlot copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    String? assignedUserId,
    String? description,
    bool? isCompleted,
    DateTime? completedAt,
    String? completedBy,
    int? creditsAwarded,
  }) {
    return ScheduleSlot(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      completedBy: completedBy ?? this.completedBy,
      creditsAwarded: creditsAwarded ?? this.creditsAwarded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'assigned_user_id': assignedUserId,
      'description': description,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
      'completed_by': completedBy,
      'credits_awarded': creditsAwarded,
    };
  }

  factory ScheduleSlot.fromJson(Map<String, dynamic> json) {
    return ScheduleSlot(
      id: json['id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      assignedUserId: json['assigned_user_id'],
      description: json['description'],
      isCompleted: json['is_completed'] == 1,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      completedBy: json['completed_by'],
      creditsAwarded: json['credits_awarded'],
    );
  }
}

class ScheduleTemplate extends Equatable {
  final String id;
  final String name;
  final ScheduleType type;
  final String description;
  final List<ScheduleSlotTemplate> slotTemplates;
  final RotationPattern defaultRotationPattern;
  final bool isSystemTemplate;
  final DateTime createdAt;

  const ScheduleTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.slotTemplates,
    required this.defaultRotationPattern,
    this.isSystemTemplate = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        description,
        slotTemplates,
        defaultRotationPattern,
        isSystemTemplate,
        createdAt,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'description': description,
      'slot_templates_json': slotTemplates.map((template) => template.toJson()).toList(),
      'default_rotation_pattern': defaultRotationPattern.toString().split('.').last,
      'is_system_template': isSystemTemplate ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ScheduleTemplate.fromJson(Map<String, dynamic> json) {
    return ScheduleTemplate(
      id: json['id'],
      name: json['name'],
      type: ScheduleType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      description: json['description'],
      slotTemplates: (json['slot_templates_json'] as List)
          .map((template) => ScheduleSlotTemplate.fromJson(template))
          .toList(),
      defaultRotationPattern: RotationPattern.values.firstWhere(
        (e) => e.toString().split('.').last == json['default_rotation_pattern'],
      ),
      isSystemTemplate: json['is_system_template'] == 1,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class ScheduleSlotTemplate extends Equatable {
  final String id;
  final String name;
  final String description;
  final Duration duration;
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final TimeOfDay startTime;
  final int creditsReward;

  const ScheduleSlotTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.dayOfWeek,
    required this.startTime,
    this.creditsReward = 5,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        duration,
        dayOfWeek,
        startTime,
        creditsReward,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'duration_minutes': duration.inMinutes,
      'day_of_week': dayOfWeek,
      'start_time_hour': startTime.hour,
      'start_time_minute': startTime.minute,
      'credits_reward': creditsReward,
    };
  }

  factory ScheduleSlotTemplate.fromJson(Map<String, dynamic> json) {
    return ScheduleSlotTemplate(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      duration: Duration(minutes: json['duration_minutes']),
      dayOfWeek: json['day_of_week'],
      startTime: TimeOfDay(
        hour: json['start_time_hour'],
        minute: json['start_time_minute'],
      ),
      creditsReward: json['credits_reward'] ?? 5,
    );
  }
}

class TimeOfDay extends Equatable {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  @override
  List<Object?> get props => [hour, minute];

  @override
  String toString() {
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }
}