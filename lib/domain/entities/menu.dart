import 'package:equatable/equatable.dart';

enum MealType { breakfast, lunch, dinner, snack }

enum MealStatus { planned, prepared, served, cancelled }

class Menu extends Equatable {
  final String id;
  final String apartmentId;
  final DateTime date;
  final List<MealPlan> meals;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? lastModified;

  const Menu({
    required this.id,
    required this.apartmentId,
    required this.date,
    required this.meals,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    this.lastModified,
  });

  @override
  List<Object?> get props => [
        id,
        apartmentId,
        date,
        meals,
        notes,
        createdBy,
        createdAt,
        lastModified,
      ];

  Menu copyWith({
    String? id,
    String? apartmentId,
    DateTime? date,
    List<MealPlan>? meals,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    return Menu(
      id: id ?? this.id,
      apartmentId: apartmentId ?? this.apartmentId,
      date: date ?? this.date,
      meals: meals ?? this.meals,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}

class MealPlan extends Equatable {
  final String id;
  final MealType type;
  final String name;
  final String? description;
  final DateTime scheduledTime;
  final String? assignedChef;
  final List<String> ingredients;
  final MealStatus status;
  final int estimatedServings;
  final String? imageUrl;

  const MealPlan({
    required this.id,
    required this.type,
    required this.name,
    this.description,
    required this.scheduledTime,
    this.assignedChef,
    required this.ingredients,
    required this.status,
    required this.estimatedServings,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        name,
        description,
        scheduledTime,
        assignedChef,
        ingredients,
        status,
        estimatedServings,
        imageUrl,
      ];

  MealPlan copyWith({
    String? id,
    MealType? type,
    String? name,
    String? description,
    DateTime? scheduledTime,
    String? assignedChef,
    List<String>? ingredients,
    MealStatus? status,
    int? estimatedServings,
    String? imageUrl,
  }) {
    return MealPlan(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      assignedChef: assignedChef ?? this.assignedChef,
      ingredients: ingredients ?? this.ingredients,
      status: status ?? this.status,
      estimatedServings: estimatedServings ?? this.estimatedServings,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class WeeklyMenuPlan extends Equatable {
  final String id;
  final String apartmentId;
  final DateTime weekStartDate;
  final List<Menu> dailyMenus;
  final String? theme;
  final double estimatedCost;
  final String createdBy;
  final DateTime createdAt;

  const WeeklyMenuPlan({
    required this.id,
    required this.apartmentId,
    required this.weekStartDate,
    required this.dailyMenus,
    this.theme,
    required this.estimatedCost,
    required this.createdBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        apartmentId,
        weekStartDate,
        dailyMenus,
        theme,
        estimatedCost,
        createdBy,
        createdAt,
      ];

  DateTime get weekEndDate => weekStartDate.add(const Duration(days: 6));

  List<MealPlan> get allMeals {
    return dailyMenus.expand((menu) => menu.meals).toList();
  }

  int get totalMeals => allMeals.length;

  Map<MealType, int> get mealTypeCount {
    final count = <MealType, int>{};
    for (final meal in allMeals) {
      count[meal.type] = (count[meal.type] ?? 0) + 1;
    }
    return count;
  }
}