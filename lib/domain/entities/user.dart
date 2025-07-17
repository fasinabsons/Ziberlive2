import 'package:equatable/equatable.dart';

enum UserRole { user, roommateAdmin }

enum SubscriptionType { 
  communityCooking, 
  drinkingWater, 
  rent, 
  utilities 
}

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String apartmentId;
  final String? roomId;
  final String? bedId;
  final List<Subscription> subscriptions;
  final int coLivingCredits;
  final DateTime createdAt;
  final DateTime lastSyncAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.apartmentId,
    this.roomId,
    this.bedId,
    required this.subscriptions,
    required this.coLivingCredits,
    required this.createdAt,
    required this.lastSyncAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        role,
        apartmentId,
        roomId,
        bedId,
        subscriptions,
        coLivingCredits,
        createdAt,
        lastSyncAt,
      ];

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? apartmentId,
    String? roomId,
    String? bedId,
    List<Subscription>? subscriptions,
    int? coLivingCredits,
    DateTime? createdAt,
    DateTime? lastSyncAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      apartmentId: apartmentId ?? this.apartmentId,
      roomId: roomId ?? this.roomId,
      bedId: bedId ?? this.bedId,
      subscriptions: subscriptions ?? this.subscriptions,
      coLivingCredits: coLivingCredits ?? this.coLivingCredits,
      createdAt: createdAt ?? this.createdAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
}

class Subscription extends Equatable {
  final String id;
  final SubscriptionType type;
  final String customName;
  final bool isActive;
  final DateTime startDate;
  final DateTime? endDate;

  const Subscription({
    required this.id,
    required this.type,
    required this.customName,
    required this.isActive,
    required this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        customName,
        isActive,
        startDate,
        endDate,
      ];

  Subscription copyWith({
    String? id,
    SubscriptionType? type,
    String? customName,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Subscription(
      id: id ?? this.id,
      type: type ?? this.type,
      customName: customName ?? this.customName,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}