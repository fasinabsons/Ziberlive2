import 'package:equatable/equatable.dart';

enum InvestmentType { 
  stocks, 
  bonds, 
  realEstate, 
  crypto, 
  mutualFunds, 
  other 
}

enum InvestmentStatus { 
  proposed, 
  approved, 
  active, 
  completed, 
  cancelled 
}

class InvestmentGroup extends Equatable {
  final String id;
  final String name;
  final String apartmentId;
  final List<String> participantIds;
  final Map<String, double> contributions;
  final double totalContributions;
  final double currentValue;
  final double monthlyReturns;
  final List<Investment> investments;
  final DateTime createdAt;

  const InvestmentGroup({
    required this.id,
    required this.name,
    required this.apartmentId,
    required this.participantIds,
    required this.contributions,
    required this.totalContributions,
    required this.currentValue,
    required this.monthlyReturns,
    required this.investments,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        apartmentId,
        participantIds,
        contributions,
        totalContributions,
        currentValue,
        monthlyReturns,
        investments,
        createdAt,
      ];

  InvestmentGroup copyWith({
    String? id,
    String? name,
    String? apartmentId,
    List<String>? participantIds,
    Map<String, double>? contributions,
    double? totalContributions,
    double? currentValue,
    double? monthlyReturns,
    List<Investment>? investments,
    DateTime? createdAt,
  }) {
    return InvestmentGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      apartmentId: apartmentId ?? this.apartmentId,
      participantIds: participantIds ?? this.participantIds,
      contributions: contributions ?? this.contributions,
      totalContributions: totalContributions ?? this.totalContributions,
      currentValue: currentValue ?? this.currentValue,
      monthlyReturns: monthlyReturns ?? this.monthlyReturns,
      investments: investments ?? this.investments,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  double getRentCoveragePercentage(double monthlyRent) {
    if (monthlyRent <= 0) return 0.0;
    return (monthlyReturns / monthlyRent) * 100;
  }

  double getUserContribution(String userId) {
    return contributions[userId] ?? 0.0;
  }

  double getUserROI(String userId) {
    final userContribution = getUserContribution(userId);
    if (userContribution <= 0 || totalContributions <= 0) return 0.0;
    
    final userShare = userContribution / totalContributions;
    final userCurrentValue = currentValue * userShare;
    
    return ((userCurrentValue - userContribution) / userContribution) * 100;
  }
}

class Investment extends Equatable {
  final String id;
  final String name;
  final String description;
  final double amount;
  final InvestmentType type;
  final double expectedReturn;
  final InvestmentStatus status;
  final DateTime investmentDate;
  final DateTime? maturityDate;
  final String proposedBy;

  const Investment({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.type,
    required this.expectedReturn,
    required this.status,
    required this.investmentDate,
    this.maturityDate,
    required this.proposedBy,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        amount,
        type,
        expectedReturn,
        status,
        investmentDate,
        maturityDate,
        proposedBy,
      ];

  Investment copyWith({
    String? id,
    String? name,
    String? description,
    double? amount,
    InvestmentType? type,
    double? expectedReturn,
    InvestmentStatus? status,
    DateTime? investmentDate,
    DateTime? maturityDate,
    String? proposedBy,
  }) {
    return Investment(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      expectedReturn: expectedReturn ?? this.expectedReturn,
      status: status ?? this.status,
      investmentDate: investmentDate ?? this.investmentDate,
      maturityDate: maturityDate ?? this.maturityDate,
      proposedBy: proposedBy ?? this.proposedBy,
    );
  }
}