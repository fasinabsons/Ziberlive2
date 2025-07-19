import 'package:dartz/dartz.dart';
import '../../domain/entities/investment_group.dart';
import '../../domain/repositories/investment_group_repository.dart';
import '../../core/error/failures.dart';
import '../datasources/local/database_helper.dart';

class InvestmentGroupRepositoryImpl implements InvestmentGroupRepository {
  final DatabaseHelper databaseHelper;

  InvestmentGroupRepositoryImpl({required this.databaseHelper});

  @override
  Future<Either<Failure, List<InvestmentGroup>>> getInvestmentGroups() async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query('investment_groups');
      
      final groups = <InvestmentGroup>[];
      for (final map in maps) {
        final group = await _mapToInvestmentGroup(map);
        groups.add(group);
      }
      
      return Right(groups);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get investment groups: $e'));
    }
  }

  @override
  Future<Either<Failure, InvestmentGroup>> getInvestmentGroupById(String groupId) async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query(
        'investment_groups',
        where: 'id = ?',
        whereArgs: [groupId],
      );
      
      if (maps.isEmpty) {
        return Left(NotFoundFailure('Investment group not found'));
      }
      
      final group = await _mapToInvestmentGroup(maps.first);
      return Right(group);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get investment group: $e'));
    }
  }

  @override
  Future<Either<Failure, List<InvestmentGroup>>> getInvestmentGroupsByApartment(String apartmentId) async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query(
        'investment_groups',
        where: 'apartment_id = ?',
        whereArgs: [apartmentId],
      );
      
      final groups = <InvestmentGroup>[];
      for (final map in maps) {
        final group = await _mapToInvestmentGroup(map);
        groups.add(group);
      }
      
      return Right(groups);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get investment groups by apartment: $e'));
    }
  }

  @override
  Future<Either<Failure, List<InvestmentGroup>>> getInvestmentGroupsByUser(String userId) async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.rawQuery('''
        SELECT ig.* FROM investment_groups ig
        JOIN investment_group_members igm ON ig.id = igm.group_id
        WHERE igm.user_id = ?
      ''', [userId]);
      
      final groups = <InvestmentGroup>[];
      for (final map in maps) {
        final group = await _mapToInvestmentGroup(map);
        groups.add(group);
      }
      
      return Right(groups);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get investment groups by user: $e'));
    }
  }

  @override
  Future<Either<Failure, InvestmentGroup>> createInvestmentGroup(InvestmentGroup group) async {
    try {
      final db = await databaseHelper.database;
      
      await db.transaction((txn) async {
        // Insert the group
        await txn.insert('investment_groups', {
          'id': group.id,
          'name': group.name,
          'apartment_id': group.apartmentId,
          'total_contributions': group.totalContributions,
          'current_value': group.currentValue,
          'monthly_returns': group.monthlyReturns,
          'created_at': group.createdAt.toIso8601String(),
        });
        
        // Insert members
        for (final participantId in group.participantIds) {
          await txn.insert('investment_group_members', {
            'group_id': group.id,
            'user_id': participantId,
            'joined_at': DateTime.now().toIso8601String(),
          });
        }
        
        // Insert contributions
        for (final entry in group.contributions.entries) {
          await txn.insert('investment_group_contributions', {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'group_id': group.id,
            'user_id': entry.key,
            'amount': entry.value,
            'contributed_at': DateTime.now().toIso8601String(),
          });
        }
      });
      
      return Right(group);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create investment group: $e'));
    }
  }

  @override
  Future<Either<Failure, InvestmentGroup>> updateInvestmentGroup(InvestmentGroup group) async {
    try {
      final db = await databaseHelper.database;
      
      await db.update(
        'investment_groups',
        {
          'name': group.name,
          'total_contributions': group.totalContributions,
          'current_value': group.currentValue,
          'monthly_returns': group.monthlyReturns,
        },
        where: 'id = ?',
        whereArgs: [group.id],
      );
      
      return Right(group);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update investment group: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteInvestmentGroup(String groupId) async {
    try {
      final db = await databaseHelper.database;
      
      await db.transaction((txn) async {
        await txn.delete('investment_group_members', where: 'group_id = ?', whereArgs: [groupId]);
        await txn.delete('investment_group_contributions', where: 'group_id = ?', whereArgs: [groupId]);
        await txn.delete('investments', where: 'group_id = ?', whereArgs: [groupId]);
        await txn.delete('investment_groups', where: 'id = ?', whereArgs: [groupId]);
      });
      
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete investment group: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addMemberToGroup(String groupId, String userId) async {
    try {
      final db = await databaseHelper.database;
      
      await db.insert('investment_group_members', {
        'group_id': groupId,
        'user_id': userId,
        'joined_at': DateTime.now().toIso8601String(),
      });
      
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add member to group: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeMemberFromGroup(String groupId, String userId) async {
    try {
      final db = await databaseHelper.database;
      
      await db.delete(
        'investment_group_members',
        where: 'group_id = ? AND user_id = ?',
        whereArgs: [groupId, userId],
      );
      
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to remove member from group: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addContribution(String groupId, String userId, double amount) async {
    try {
      final db = await databaseHelper.database;
      
      await db.transaction((txn) async {
        // Add contribution record
        await txn.insert('investment_group_contributions', {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'group_id': groupId,
          'user_id': userId,
          'amount': amount,
          'contributed_at': DateTime.now().toIso8601String(),
        });
        
        // Update group total contributions
        await txn.rawUpdate('''
          UPDATE investment_groups 
          SET total_contributions = total_contributions + ?
          WHERE id = ?
        ''', [amount, groupId]);
      });
      
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add contribution: $e'));
    }
  }

  @override
  Future<Either<Failure, Investment>> proposeInvestment(String groupId, Investment investment) async {
    try {
      final db = await databaseHelper.database;
      
      await db.insert('investments', {
        'id': investment.id,
        'group_id': groupId,
        'name': investment.name,
        'description': investment.description,
        'amount': investment.amount,
        'type': investment.type.toString().split('.').last,
        'expected_return': investment.expectedReturn,
        'status': investment.status.toString().split('.').last,
        'investment_date': investment.investmentDate.toIso8601String(),
        'maturity_date': investment.maturityDate?.toIso8601String(),
        'proposed_by': investment.proposedBy,
      });
      
      return Right(investment);
    } catch (e) {
      return Left(DatabaseFailure('Failed to propose investment: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> approveInvestment(String groupId, String investmentId) async {
    try {
      final db = await databaseHelper.database;
      
      await db.update(
        'investments',
        {'status': InvestmentStatus.approved.toString().split('.').last},
        where: 'id = ? AND group_id = ?',
        whereArgs: [investmentId, groupId],
      );
      
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to approve investment: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> rejectInvestment(String groupId, String investmentId) async {
    try {
      final db = await databaseHelper.database;
      
      await db.update(
        'investments',
        {'status': InvestmentStatus.cancelled.toString().split('.').last},
        where: 'id = ? AND group_id = ?',
        whereArgs: [investmentId, groupId],
      );
      
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to reject investment: $e'));
    }
  }

  @override
  Future<Either<Failure, InvestmentGroup>> updateGroupValue(String groupId, double newValue) async {
    try {
      final db = await databaseHelper.database;
      
      await db.update(
        'investment_groups',
        {'current_value': newValue},
        where: 'id = ?',
        whereArgs: [groupId],
      );
      
      final result = await getInvestmentGroupById(groupId);
      return result;
    } catch (e) {
      return Left(DatabaseFailure('Failed to update group value: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateMonthlyReturns(String groupId, double monthlyReturns) async {
    try {
      final db = await databaseHelper.database;
      
      await db.update(
        'investment_groups',
        {'monthly_returns': monthlyReturns},
        where: 'id = ?',
        whereArgs: [groupId],
      );
      
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update monthly returns: $e'));
    }
  }

  Future<InvestmentGroup> _mapToInvestmentGroup(Map<String, dynamic> map) async {
    final db = await databaseHelper.database;
    
    // Get members
    final memberMaps = await db.query(
      'investment_group_members',
      where: 'group_id = ?',
      whereArgs: [map['id']],
    );
    final participantIds = memberMaps.map((m) => m['user_id'] as String).toList();
    
    // Get contributions
    final contributionMaps = await db.query(
      'investment_group_contributions',
      where: 'group_id = ?',
      whereArgs: [map['id']],
    );
    final contributions = <String, double>{};
    for (final contrib in contributionMaps) {
      final userId = contrib['user_id'] as String;
      final amount = contrib['amount'] as double;
      contributions[userId] = (contributions[userId] ?? 0.0) + amount;
    }
    
    // Get investments
    final investmentMaps = await db.query(
      'investments',
      where: 'group_id = ?',
      whereArgs: [map['id']],
    );
    final investments = investmentMaps.map((investMap) => Investment(
      id: investMap['id'] as String,
      name: investMap['name'] as String,
      description: investMap['description'] as String,
      amount: investMap['amount'] as double,
      type: InvestmentType.values.firstWhere(
        (e) => e.toString().split('.').last == investMap['type'],
      ),
      expectedReturn: investMap['expected_return'] as double,
      status: InvestmentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == investMap['status'],
      ),
      investmentDate: DateTime.parse(investMap['investment_date'] as String),
      maturityDate: investMap['maturity_date'] != null 
          ? DateTime.parse(investMap['maturity_date'] as String) 
          : null,
      proposedBy: investMap['proposed_by'] as String,
    )).toList();
    
    return InvestmentGroup(
      id: map['id'] as String,
      name: map['name'] as String,
      apartmentId: map['apartment_id'] as String,
      participantIds: participantIds,
      contributions: contributions,
      totalContributions: map['total_contributions'] as double,
      currentValue: map['current_value'] as double,
      monthlyReturns: map['monthly_returns'] as double,
      investments: investments,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}