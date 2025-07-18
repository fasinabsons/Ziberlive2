import 'package:equatable/equatable.dart';
import '../../../../domain/entities/task.dart';
import '../../../../domain/entities/user.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskCreated extends TaskState {}

class TasksLoaded extends TaskState {
  final List<Task> tasks;

  const TasksLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TaskUsersLoaded extends TaskState {
  final List<User> users;

  const TaskUsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class TaskUpdated extends TaskState {
  final Task task;

  const TaskUpdated(this.task);

  @override
  List<Object?> get props => [task];
}

class TaskNotificationSent extends TaskState {
  final Task task;
  final String message;

  const TaskNotificationSent(this.task, this.message);

  @override
  List<Object?> get props => [task, message];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}