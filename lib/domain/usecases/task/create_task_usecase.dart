import 'package:dartz/dartz.dart';
import '../../entities/task.dart';
import '../../repositories/task_repository.dart';
import '../../../core/error/failures.dart';
import '../../../core/utils/result.dart';

class CreateTaskUseCase {
  final TaskRepository repository;

  CreateTaskUseCase(this.repository);

  Future<Either<Failure, Task>> call(Task task) async {
    try {
      // Validate task data
      if (task.name.trim().isEmpty) {
        return Left(ValidationFailure('Task name cannot be empty'));
      }
      
      if (task.description.trim().isEmpty) {
        return Left(ValidationFailure('Task description cannot be empty'));
      }
      
      if (task.dueDate.isBefore(DateTime.now())) {
        return Left(ValidationFailure('Due date cannot be in the past'));
      }
      
      if (task.assignedTo.isEmpty) {
        return Left(ValidationFailure('Task must be assigned to a user'));
      }

      // Create the task
      final result = await repository.createTask(task);
      return result.fold(
        (failure) => Left(failure),
        (createdTask) {
          // TODO: Send notification to assigned user
          _sendTaskAssignmentNotification(createdTask);
          return Right(createdTask);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to create task: ${e.toString()}'));
    }
  }

  void _sendTaskAssignmentNotification(Task task) {
    // TODO: Implement notification service
    // This would send a notification to the assigned user
    print('Notification: New task "${task.name}" assigned to ${task.assignedTo}');
  }
}