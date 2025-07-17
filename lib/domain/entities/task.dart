import 'package:equatable/equatable.dart';

enum TaskStatus { 
  pending, 
  inProgress, 
  completed, 
  overdue 
}

enum TaskType { 
  cleaning, 
  cooking, 
  maintenance, 
  shopping, 
  custom 
}

class Task extends Equatable {
  final String id;
  final String name;
  final String description;
  final String apartmentId;
  final String assignedTo;
  final String createdBy;
  final DateTime dueDate;
  final TaskStatus status;
  final int creditsReward;
  final TaskType type;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Task({
    required this.id,
    required this.name,
    required this.description,
    required this.apartmentId,
    required this.assignedTo,
    required this.createdBy,
    required this.dueDate,
    required this.status,
    required this.creditsReward,
    required this.type,
    required this.createdAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        apartmentId,
        assignedTo,
        createdBy,
        dueDate,
        status,
        creditsReward,
        type,
        createdAt,
        completedAt,
      ];

  Task copyWith({
    String? id,
    String? name,
    String? description,
    String? apartmentId,
    String? assignedTo,
    String? createdBy,
    DateTime? dueDate,
    TaskStatus? status,
    int? creditsReward,
    TaskType? type,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      apartmentId: apartmentId ?? this.apartmentId,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      creditsReward: creditsReward ?? this.creditsReward,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

enum ScheduleType { 
  cleaning, 
  cooking, 
  communityCooking 
}

enum RotationPattern { 
  weekly, 
  biweekly, 
  monthly 
}

class Schedule extends Equatable {
  final String id;
  final String name;
  final ScheduleType type;
  final String apartmentId;
  final List<ScheduleSlot> slots;
  final RotationPattern rotationPattern;
  final DateTime startDate;
  final DateTime? endDate;

  const Schedule({
    required this.id,
    required this.name,
    required this.type,
    required this.apartmentId,
    required this.slots,
    required this.rotationPattern,
    required this.startDate,
    this.endDate,
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
      ];
}

class ScheduleSlot extends Equatable {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String assignedUserId;
  final String? description;
  final bool isCompleted;

  const ScheduleSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.assignedUserId,
    this.description,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [
        id,
        startTime,
        endTime,
        assignedUserId,
        description,
        isCompleted,
      ];
}