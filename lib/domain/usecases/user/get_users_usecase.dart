import 'package:dartz/dartz.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';
import '../../../core/error/failures.dart';

class GetUsersUseCase {
  final UserRepository repository;

  GetUsersUseCase(this.repository);

  Future<Either<Failure, List<User>>> call(String apartmentId) async {
    try {
      final result = await repository.getUsersByApartment(apartmentId);
      return result.fold(
        (failure) => Left(failure),
        (users) {
          // Sort users by name for better UX
          final sortedUsers = List<User>.from(users);
          sortedUsers.sort((a, b) => a.name.compareTo(b.name));
          return Right(sortedUsers);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get users: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<User>>> getActiveUsers(String apartmentId) async {
    try {
      final result = await repository.getUsersByApartment(apartmentId);
      return result.fold(
        (failure) => Left(failure),
        (users) {
          // Filter for active users (those who have synced recently)
          final now = DateTime.now();
          final activeUsers = users.where((user) {
            final daysSinceLastSync = now.difference(user.lastSyncAt).inDays;
            return daysSinceLastSync <= 7; // Active within last week
          }).toList();
          
          activeUsers.sort((a, b) => a.name.compareTo(b.name));
          return Right(activeUsers);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get active users: ${e.toString()}'));
    }
  }

  Future<Either<Failure, User>> getUserById(String userId) async {
    try {
      final result = await repository.getUserById(userId);
      return result;
    } catch (e) {
      return Left(ServerFailure('Failed to get user: ${e.toString()}'));
    }
  }
}