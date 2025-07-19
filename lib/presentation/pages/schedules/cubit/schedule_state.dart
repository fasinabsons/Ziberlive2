import 'package:equatable/equatable.dart';
import '../../../../domain/entities/schedule.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class SchedulesLoaded extends ScheduleState {
  final List<Schedule> schedules;

  const SchedulesLoaded(this.schedules);

  @override
  List<Object?> get props => [schedules];
}

class ScheduleCreated extends ScheduleState {
  final Schedule schedule;

  const ScheduleCreated(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

class ScheduleUpdated extends ScheduleState {
  final Schedule schedule;

  const ScheduleUpdated(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

class ScheduleDeleted extends ScheduleState {
  final String scheduleId;

  const ScheduleDeleted(this.scheduleId);

  @override
  List<Object?> get props => [scheduleId];
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}

class SlotCompleted extends ScheduleState {
  final String slotId;
  final int creditsAwarded;

  const SlotCompleted(this.slotId, this.creditsAwarded);

  @override
  List<Object?> get props => [slotId, creditsAwarded];
}

class AssignmentsRotated extends ScheduleState {
  final String scheduleId;

  const AssignmentsRotated(this.scheduleId);

  @override
  List<Object?> get props => [scheduleId];
}