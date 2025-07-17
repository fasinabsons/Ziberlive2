import 'package:equatable/equatable.dart';

enum GroceryTeamStatus { active, completed, cancelled }

class GroceryTeam extends Equatable {
  final String id;
  final String apartmentId;
  final String name;
  final List<String> memberIds;
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final double budgetLimit;
  final double totalSpent;
  final List<GroceryExpense> expenses;
  final GroceryTeamStatus status;
  final String? notes;
  final DateTime createdAt;

  const GroceryTeam({
    required this.id,
    required this.apartmentId,
    required this.name,
    required this.memberIds,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.budgetLimit,
    required this.totalSpent,
    required this.expenses,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        apartmentId,
        name,
        memberIds,
        weekStartDate,
        weekEndDate,
        budgetLimit,
        totalSpent,
        expenses,
        status,
        notes,
        createdAt,
      ];

  GroceryTeam copyWith({
    String? id,
    String? apartmentId,
    String? name,
    List<String>? memberIds,
    DateTime? weekStartDate,
    DateTime? weekEndDate,
    double? budgetLimit,
    double? totalSpent,
    List<GroceryExpense>? expenses,
    GroceryTeamStatus? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return GroceryTeam(
      id: id ?? this.id,
      apartmentId: apartmentId ?? this.apartmentId,
      name: name ?? this.name,
      memberIds: memberIds ?? this.memberIds,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      weekEndDate: weekEndDate ?? this.weekEndDate,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      totalSpent: totalSpent ?? this.totalSpent,
      expenses: expenses ?? this.expenses,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  double get remainingBudget => budgetLimit - totalSpent;
  bool get isOverBudget => totalSpent > budgetLimit;
  double get budgetUsagePercentage => budgetLimit > 0 ? (totalSpent / budgetLimit) * 100 : 0;
}

class GroceryExpense extends Equatable {
  final String id;
  final String teamId;
  final String description;
  final double amount;
  final String store;
  final DateTime purchaseDate;
  final String purchasedBy;
  final List<String> items;
  final String? receiptImageUrl;
  final String? notes;

  const GroceryExpense({
    required this.id,
    required this.teamId,
    required this.description,
    required this.amount,
    required this.store,
    required this.purchaseDate,
    required this.purchasedBy,
    required this.items,
    this.receiptImageUrl,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        teamId,
        description,
        amount,
        store,
        purchaseDate,
        purchasedBy,
        items,
        receiptImageUrl,
        notes,
      ];

  GroceryExpense copyWith({
    String? id,
    String? teamId,
    String? description,
    double? amount,
    String? store,
    DateTime? purchaseDate,
    String? purchasedBy,
    List<String>? items,
    String? receiptImageUrl,
    String? notes,
  }) {
    return GroceryExpense(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      store: store ?? this.store,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasedBy: purchasedBy ?? this.purchasedBy,
      items: items ?? this.items,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      notes: notes ?? this.notes,
    );
  }
}

class GroceryRotationSchedule extends Equatable {
  final String id;
  final String apartmentId;
  final List<GroceryTeamAssignment> assignments;
  final DateTime startDate;
  final int rotationWeeks;
  final bool isActive;

  const GroceryRotationSchedule({
    required this.id,
    required this.apartmentId,
    required this.assignments,
    required this.startDate,
    required this.rotationWeeks,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        apartmentId,
        assignments,
        startDate,
        rotationWeeks,
        isActive,
      ];

  GroceryTeamAssignment? getCurrentAssignment() {
    final now = DateTime.now();
    return assignments.firstWhere(
      (assignment) =>
          assignment.weekStartDate.isBefore(now) &&
          assignment.weekEndDate.isAfter(now),
      orElse: () => assignments.first,
    );
  }

  GroceryTeamAssignment? getNextAssignment() {
    final current = getCurrentAssignment();
    if (current == null) return null;
    
    final currentIndex = assignments.indexOf(current);
    if (currentIndex < assignments.length - 1) {
      return assignments[currentIndex + 1];
    }
    return assignments.first; // Rotate back to first
  }
}

class GroceryTeamAssignment extends Equatable {
  final String id;
  final List<String> memberIds;
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final double budgetLimit;

  const GroceryTeamAssignment({
    required this.id,
    required this.memberIds,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.budgetLimit,
  });

  @override
  List<Object?> get props => [
        id,
        memberIds,
        weekStartDate,
        weekEndDate,
        budgetLimit,
      ];
}