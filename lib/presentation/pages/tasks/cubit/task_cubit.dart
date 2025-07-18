import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/task.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/usecases/task/create_task_usecase.dart';
import '../../../../domain/usecases/task/get_tasks_usecase.dart';
import '../../../../domain/usecases/task/update_task_usecase.dart';
import '../../../../domain/usecases/user/get_users_usecase.dart';
import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final CreateTaskUseCase _createTaskUseCase;
  final GetTasksUseCase _getTasksUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final GetUsersUseCase _getUsersUseCase;

  TaskCubit({
    required CreateTaskUseCase createTaskUseCase,
    required GetTasksUseCase getTasksUseCase,
    required UpdateTaskUseCase updateTaskUseCase,
    required GetUsersUseCase getUsersUseCase,
  })  : _createTaskUseCase = createTaskUseCase,
        _getTasksUseCase = getTasksUseCase,
        _updateTaskUseCase = updateTaskUseCase,
        _getUsersUseCase = getUsersUseCase,
        super(TaskInitial());

  Future<void> createTask(Task task) async {
    emit(TaskLoading());
    try {
      final result = await _createTaskUseCase(task);
      result.fold(
        (failure) => emit(TaskError(failure.message)),
        (success) => emit(TaskCreated()),
      );
    } catch (e) {
      emit(TaskError('Failed to create task: ${e.toString()}'));
    }
  }

  Future<void> loadTasks({String? apartmentId}) async {
    emit(TaskLoading());
    try {
      final result = await _getTasksUseCase(apartmentId ?? 'current_apartment');
      result.fold(
        (failure) => emit(TaskError(failure.message)),
        (tasks) => emit(TasksLoaded(tasks)),
      );
    } catch (e) {
      emit(TaskError('Failed to load tasks: ${e.toString()}'));
    }
  }

  Future<void> loadUsers() async {
    emit(TaskLoading());
    try {
      final result = await _getUsersUseCase('current_apartment');
      result.fold(
        (failure) => emit(TaskError(failure.message)),
        (users) => emit(TaskUsersLoaded(users)),
      );
    } catch (e) {
      emit(TaskError('Failed to load users: ${e.toString()}'));
    }
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    emit(TaskLoading());
    try {
      final result = await _updateTaskUseCase(taskId, status);
      result.fold(
        (failure) => emit(TaskError(failure.message)),
        (task) => emit(TaskUpdated(task)),
      );
    } catch (e) {
      emit(TaskError('Failed to update task: ${e.toString()}'));
    }
  }

  Future<void> completeTask(String taskId) async {
    await updateTaskStatus(taskId, TaskStatus.completed);
  }

  Future<void> assignTask(String taskId, String userId) async {
    emit(TaskLoading());
    try {
      final result = await _updateTaskUseCase(taskId, null, assignedTo: userId);
      result.fold(
        (failure) => emit(TaskError(failure.message)),
        (task) => emit(TaskUpdated(task)),
      );
    } catch (e) {
      emit(TaskError('Failed to assign task: ${e.toString()}'));
    }
  }

  void sendTaskNotification(Task task, String message) {
    // TODO: Implement notification service
    emit(TaskNotificationSent(task, message));
  }
}