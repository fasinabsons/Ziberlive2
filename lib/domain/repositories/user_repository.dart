import '../entities/user.dart';
import '../../core/utils/result.dart';
import '../../core/error/failures.dart';

abstract class UserRepository {
  Future<Result<User>> createUser(User user);
  Future<Result<User?>> getUserById(String id);
  Future<Result<List<User>>> getUsersByApartmentId(String apartmentId);
  Future<Result<User>> updateUser(User user);
  Future<Result<void>> deleteUser(String id);
  Future<Result<List<User>>> getUsersBySubscriptionType(
    String apartmentId, 
    SubscriptionType subscriptionType,
  );
  Future<Result<void>> updateUserCredits(String userId, int credits);
  Future<Result<User?>> getCurrentUser();
  Future<Result<void>> setCurrentUser(User user);
}