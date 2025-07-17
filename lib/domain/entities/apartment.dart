import 'package:equatable/equatable.dart';

class Apartment extends Equatable {
  final String id;
  final String name;
  final String address;
  final List<String> adminIds;
  final List<String> memberIds;
  final ApartmentSettings settings;
  final DateTime createdAt;

  const Apartment({
    required this.id,
    required this.name,
    required this.address,
    required this.adminIds,
    required this.memberIds,
    required this.settings,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        adminIds,
        memberIds,
        settings,
        createdAt,
      ];

  Apartment copyWith({
    String? id,
    String? name,
    String? address,
    List<String>? adminIds,
    List<String>? memberIds,
    ApartmentSettings? settings,
    DateTime? createdAt,
  }) {
    return Apartment(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      adminIds: adminIds ?? this.adminIds,
      memberIds: memberIds ?? this.memberIds,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ApartmentSettings extends Equatable {
  final bool communityCookingEnabled;
  final double communityCookingFixedRate;
  final bool variableBillingEnabled;
  final bool adminIncludedInBills;
  final int defaultTaskCredits;
  final bool anonymousVotingAllowed;

  const ApartmentSettings({
    required this.communityCookingEnabled,
    required this.communityCookingFixedRate,
    required this.variableBillingEnabled,
    required this.adminIncludedInBills,
    required this.defaultTaskCredits,
    required this.anonymousVotingAllowed,
  });

  @override
  List<Object?> get props => [
        communityCookingEnabled,
        communityCookingFixedRate,
        variableBillingEnabled,
        adminIncludedInBills,
        defaultTaskCredits,
        anonymousVotingAllowed,
      ];

  ApartmentSettings copyWith({
    bool? communityCookingEnabled,
    double? communityCookingFixedRate,
    bool? variableBillingEnabled,
    bool? adminIncludedInBills,
    int? defaultTaskCredits,
    bool? anonymousVotingAllowed,
  }) {
    return ApartmentSettings(
      communityCookingEnabled: communityCookingEnabled ?? this.communityCookingEnabled,
      communityCookingFixedRate: communityCookingFixedRate ?? this.communityCookingFixedRate,
      variableBillingEnabled: variableBillingEnabled ?? this.variableBillingEnabled,
      adminIncludedInBills: adminIncludedInBills ?? this.adminIncludedInBills,
      defaultTaskCredits: defaultTaskCredits ?? this.defaultTaskCredits,
      anonymousVotingAllowed: anonymousVotingAllowed ?? this.anonymousVotingAllowed,
    );
  }
}