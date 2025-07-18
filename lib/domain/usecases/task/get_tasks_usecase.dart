import 'package:dartz/dartz.dart';
import '../../entities/task.dart';
import '../../repositories/task_repository.dart';
import '../../../core/error/failures.dart';

class GetTasksUseCase {
  final TaskRepository repository;

  GetTasksUseCase(this.repository);

  Future<Either<Failure, List<Task>>> call(String apartmentId, {
    String? assignedTo,
    TaskStatus? status,
    TaskType? type,
  }) async {
    try {
      final result = await repository.getTasks(
        apartmentId,
        assignedTo: assignedTo,
        status: status,
        type: type,
      );
      
      return result.fold(
        (failure) => Left(failure),
        (tasks) {
          // Sort tasks by due date (earliest first)
          final sortedTasks = List<Task>.from(tasks);
          sortedTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
          return Right(sortedTasks);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get tasks: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<Task>>> getMyTasks(String userId) async {
    try {
      final result = await repository.getTasksByUser(userId);
      return result.fold(
        (failure) => Left(failure),
        (tasks) {
          // Sort by priority: overdue, due today, upcoming
          final sortedTasks = List<Task>.from(tasks);
          sortedTasks.sort((a, b) {
            final now = DateTime.now();
            final aOverdue = a.dueDate.isBefore(now);
            final bOverdue = b.dueDate.isBefore(now);
            
            if (aOverdue && !bOverdue) return -1;
            if (!aOverdue && bOverdue) return 1;
            
            return a.dueDate.compareTo(b.dueDate);
          });
          return Right(sortedTasks);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get user tasks: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<Task>>> getOverdueTasks(String apartmentId) async {
    try {
      final result = await repository.getTasks(apartmentId);
      return result.fold(
        (failure) => Left(failure),
        (tasks) {
          final now = DateTime.now();
          final overdueTasks = tasks
              .where((task) => 
                  task.dueDate.isBefore(now) && 
                  task.status != TaskStatus.completed)
              .toList();
          
          overdueTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
          return Right(overdueTasks);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get overdue tasks: ${e.toString()}'));
    }
  }
}