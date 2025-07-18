import 'package:dartz/dartz.dart';
import '../../entities/task.dart';
import '../../repositories/task_repository.dart';
import '../../../core/error/failures.dart';
import '../../../core/services/gamification_service.dart';
import '../../entities/gamification.dart';

class UpdateTaskUseCase {
  final TaskRepository repository;
  final GamificationService gamificationService;

  UpdateTaskUseCase(this.repository, this.gamificationService);

  Future<Either<Failure, Task>> call(
    String taskId,
    TaskStatus? status, {
    String? assignedTo,
    String? name,
    String? description,
    DateTime? dueDate,
    int? creditsReward,
  }) async {
    try {
      // Get the current task
      final taskResult = await repository.getTaskById(taskId);
      return taskResult.fold(
        (failure) => Left(failure),
        (currentTask) async {
          // Create updated task
          final updatedTask = Task(
            id: currentTask.id,
            name: name ?? currentTask.name,
            description: description ?? currentTask.description,
            apartmentId: currentTask.apartmentId,
            assignedTo: assignedTo ?? currentTask.assignedTo,
            createdBy: currentTask.createdBy,
            dueDate: dueDate ?? currentTask.dueDate,
            status: status ?? currentTask.status,
            creditsReward: creditsReward ?? currentTask.creditsReward,
            type: currentTask.type,
            createdAt: currentTask.createdAt,
          );

          // Update the task
          final updateResult = await repository.updateTask(updatedTask);
          return updateResult.fold(
            (failure) => Left(failure),
            (task) {
              // Handle status change notifications
              if (status != null && status != currentTask.status) {
                _handleStatusChangeNotification(task, currentTask.status, status);
              }
              
              // Handle reassignment notifications
              if (assignedTo != null && assignedTo != currentTask.assignedTo) {
                _handleReassignmentNotification(task, currentTask.assignedTo, assignedTo);
              }
              
              return Right(task);
            },
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to update task: ${e.toString()}'));
    }
  }

  Future<Either<Failure, Task>> completeTask(String taskId, String userId) async {
    try {
      final result = await call(taskId, TaskStatus.completed);
      return result.fold(
        (failure) => Left(failure),
        (task) async {
          // Award credits for task completion
          await _awardCreditsForCompletion(task, userId);
          
          // Update completion streak
          await _updateCompletionStreak(userId, true);
          
          return Right(task);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to complete task: ${e.toString()}'));
    }
  }

  void _handleStatusChangeNotification(Task task, TaskStatus oldStatus, TaskStatus newStatus) {
    // TODO: Implement notification service
    switch (newStatus) {
      case TaskStatus.completed:
        print('Notification: Task "${task.name}" has been completed!');
        break;
      case TaskStatus.inProgress:
        print('Notification: Task "${task.name}" is now in progress');
        break;
      case TaskStatus.pending:
        print('Notification: Task "${task.name}" is pending');
        break;
    }
  }

  void _handleReassignmentNotification(Task task, String oldAssignee, String newAssignee) {
    // TODO: Implement notification service
    print('Notification: Task "${task.name}" reassigned from $oldAssignee to $newAssignee');
  }

  Future<void> _awardCreditsForCompletion(Task task, String userId) async {
    await gamificationService.awardCredits(
      userId,
      task.creditsReward,
      CreditReason.taskCompletion,
      description: 'Completed task: ${task.name}',
      relatedEntityId: task.id,
    );
  }

  Future<void> _updateCompletionStreak(String userId, bool completed) async {
    await gamificationService.updateStreak(userId, 'task', completed);
  }
}