import 'dart:convert';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../core/utils/result.dart';
import '../../core/error/failures.dart';
import '../datasources/local/database_helper.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final DatabaseHelper _databaseHelper;
  final SharedPreferences _sharedPreferences;

  UserRepositoryImpl(this._databaseHelper, this._sharedPreferences);

  @override
  Future<Result<User>> createUser(User user) async {
    try {
      final db = await _databaseHelper.database;
      
      final userMap = {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'role': user.role.name,
        'apartment_id': user.apartmentId,
        'room_id': user.roomId,
        'bed_id': user.bedId,
        'subscriptions_json': jsonEncode(user.subscriptions.map((s) => {
          'id': s.id,
          'type': s.type.name,
          'customName': s.customName,
          'isActive': s.isActive,
          'startDate': s.startDate.toIso8601String(),
          'endDate': s.endDate?.toIso8601String(),
        }).toList()),
        'co_living_credits': user.coLivingCredits,
        'created_at': user.createdAt.toIso8601String(),
        'last_sync_at': user.lastSyncAt.toIso8601String(),
      };

      await db.insert('users', userMap);
      return Success(user);
    } catch (e) {
      return Error(DatabaseFailure(message: 'Failed to create user: $e'));
    }
  }

  @override
  Future<Result<User?>> getUserById(String id) async {
    try {
      final db = await _databaseHelper.database;
      final results = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (results.isEmpty) {
        return const Success(null);
      }

      final user = _mapToUser(results.first);
      return Success(user);
    } catch (e) {
      return Error(DatabaseFailure(message: 'Failed to get user: $e'));
    }
  }

  @override
  Future<Result<List<User>>> getUsersByApartmentId(String apartmentId) async {
    try {
      final db = await _databaseHelper.database;
      final results = await db.query(
        'users',
        where: 'apartment_id = ?',
        whereArgs: [apartmentId],
      );

      final users = results.map(_mapToUser).toList();
      return Success(users);
    } catch (e) {
      return Error(DatabaseFailure(message: 'Failed to get users by apartment: $e'));
    }
  }

  @override
  Future<Result<User>> updateUser(User user) async {
    try {
      final db = await _databaseHelper.database;
      
      final userMap = {
        'name': user.name,
        'email': user.email,
        'role': user.role.name,
        'apartment_id': user.apartmentId,
        'room_id': user.roomId,
        'bed_id': user.bedId,
        'subscriptions_json': jsonEncode(user.subscriptions.map((s) => {
          'id': s.id,
          'type': s.type.name,
          'customName': s.customName,
          'isActive': s.isActive,
          'startDate': s.startDate.toIso8601String(),
          'endDate': s.endDate?.toIso8601String(),
        }).toList()),
        'co_living_credits': user.coLivingCredits,
        'last_sync_at': DateTime.now().toIso8601String(),
      };

      await db.update(
        'users',
        userMap,
        where: 'id = ?',
        whereArgs: [user.id],
      );

      return Success(user);
    } catch (e) {
      return Error(DatabaseFailure(message: 'Failed to update user: $e'));
    }
  }

  @override
  Future<Result<void>> deleteUser(String id) async {
    try {
      final db = await _databaseHelper.database;
      await db.delete(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(message: 'Failed to delete user: $e'));
    }
  }

  @override
  Future<Result<List<User>>> getUsersBySubscriptionType(
    String apartmentId,
    SubscriptionType subscriptionType,
  ) async {
    try {
      final db = await _databaseHelper.database;
      final results = await db.query(
        'users',
        where: 'apartment_id = ?',
        whereArgs: [apartmentId],
      );

      final users = results
          .map(_mapToUser)
          .where((user) => user.subscriptions
              .any((sub) => sub.type == subscriptionType && sub.isActive))
          .toList();

      return Success(users);
    } catch (e) {
      return Error(DatabaseFailure(message: 'Failed to get users by subscription: $e'));
    }
  }

  @override
  Future<Result<void>> updateUserCredits(String userId, int credits) async {
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'users',
        {'co_living_credits': credits},
        where: 'id = ?',
        whereArgs: [userId],
      );
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(message: 'Failed to update user credits: $e'));
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final userId = _sharedPreferences.getString('current_user_id');
      if (userId == null) {
        return const Success(null);
      }
      return await getUserById(userId);
    } catch (e) {
      return Error(DatabaseFailure(message: 'Failed to get current user: $e'));
    }
  }

  @override
  Future<Result<void>> setCurrentUser(User user) async {
    try {
      await _sharedPreferences.setString('current_user_id', user.id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(message: 'Failed to set current user: $e'));
    }
  }

  User _mapToUser(Map<String, dynamic> map) {
    final subscriptionsJson = jsonDecode(map['subscriptions_json'] as String) as List;
    final subscriptions = subscriptionsJson.map((subMap) => Subscription(
      id: subMap['id'],
      type: SubscriptionType.values.firstWhere((e) => e.name == subMap['type']),
      customName: subMap['customName'],
      isActive: subMap['isActive'],
      startDate: DateTime.parse(subMap['startDate']),
      endDate: subMap['endDate'] != null ? DateTime.parse(subMap['endDate']) : null,
    )).toList();

    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      role: UserRole.values.firstWhere((e) => e.name == map['role']),
      apartmentId: map['apartment_id'],
      roomId: map['room_id'],
      bedId: map['bed_id'],
      subscriptions: subscriptions,
      coLivingCredits: map['co_living_credits'],
      createdAt: DateTime.parse(map['created_at']),
      lastSyncAt: DateTime.parse(map['last_sync_at']),
    );
  }
}