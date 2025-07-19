import 'package:equatable/equatable.dart';
import '../../../core/services/community_board_service.dart';

abstract class CommunityBoardState extends Equatable {
  const CommunityBoardState();

  @override
  List<Object?> get props => [];
}

class CommunityBoardInitial extends CommunityBoardState {}

class CommunityBoardLoading extends CommunityBoardState {}

class CommunityBoardLoaded extends CommunityBoardState {
  final List<CommunityTip> tips;
  final List<CommunityEvent> events;
  final List<LocalDeal> deals;
  final TipCategory? selectedCategory;
  final TipSortOrder sortOrder;

  const CommunityBoardLoaded({
    required this.tips,
    required this.events,
    required this.deals,
    this.selectedCategory,
    required this.sortOrder,
  });

  @override
  List<Object?> get props => [
    tips,
    events,
    deals,
    selectedCategory,
    sortOrder,
  ];

  CommunityBoardLoaded copyWith({
    List<CommunityTip>? tips,
    List<CommunityEvent>? events,
    List<LocalDeal>? deals,
    TipCategory? selectedCategory,
    TipSortOrder? sortOrder,
  }) {
    return CommunityBoardLoaded(
      tips: tips ?? this.tips,
      events: events ?? this.events,
      deals: deals ?? this.deals,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class CommunityBoardError extends CommunityBoardState {
  final String message;

  const CommunityBoardError(this.message);

  @override
  List<Object> get props => [message];
} 