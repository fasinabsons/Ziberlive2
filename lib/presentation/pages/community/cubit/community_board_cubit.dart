import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/community_board_service.dart';
import 'community_board_state.dart';

class CommunityBoardCubit extends Cubit<CommunityBoardState> {
  final CommunityBoardService _communityBoardService = CommunityBoardService();
  
  CommunityBoardCubit() : super(CommunityBoardInitial());

  void loadData() {
    emit(CommunityBoardLoading());
    
    try {
      _communityBoardService.initializeMockData();
      
      final tips = _communityBoardService.getTips();
      final events = _communityBoardService.getUpcomingEvents();
      final deals = _communityBoardService.getActiveDeals();
      
      emit(CommunityBoardLoaded(
        tips: tips,
        events: events,
        deals: deals,
        selectedCategory: null,
        sortOrder: TipSortOrder.newest,
      ));
    } catch (e) {
      emit(CommunityBoardError('Failed to load community board data: $e'));
    }
  }

  void filterByCategory(TipCategory? category) {
    final currentState = state;
    if (currentState is CommunityBoardLoaded) {
      try {
        final filteredTips = _communityBoardService.getTips(
          category: category,
          sortOrder: currentState.sortOrder,
        );
        
        emit(currentState.copyWith(
          tips: filteredTips,
          selectedCategory: category,
        ));
      } catch (e) {
        emit(CommunityBoardError('Failed to filter tips: $e'));
      }
    }
  }

  void sortBy(TipSortOrder sortOrder) {
    final currentState = state;
    if (currentState is CommunityBoardLoaded) {
      try {
        final sortedTips = _communityBoardService.getTips(
          category: currentState.selectedCategory,
          sortOrder: sortOrder,
        );
        
        emit(currentState.copyWith(
          tips: sortedTips,
          sortOrder: sortOrder,
        ));
      } catch (e) {
        emit(CommunityBoardError('Failed to sort tips: $e'));
      }
    }
  }

  void searchTips(String query) {
    final currentState = state;
    if (currentState is CommunityBoardLoaded) {
      try {
        final searchResults = _communityBoardService.getTips(
          category: currentState.selectedCategory,
          searchQuery: query,
          sortOrder: currentState.sortOrder,
        );
        
        emit(currentState.copyWith(tips: searchResults));
      } catch (e) {
        emit(CommunityBoardError('Failed to search tips: $e'));
      }
    }
  }

  void voteTip(String tipId, bool isUpvote) async {
    final result = await _communityBoardService.voteTip(
      tipId: tipId,
      userId: 'current_user', // In real app, get from auth service
      isUpvote: isUpvote,
    );

    result.fold(
      (failure) => emit(CommunityBoardError(failure.message)),
      (updatedTip) {
        // Refresh the tips list
        loadData();
      },
    );
  }

  void rsvpToEvent(String eventId) async {
    final result = await _communityBoardService.rsvpToEvent(
      eventId: eventId,
      userId: 'current_user', // In real app, get from auth service
    );

    result.fold(
      (failure) => emit(CommunityBoardError(failure.message)),
      (updatedEvent) {
        // Refresh the events list
        loadData();
      },
    );
  }

  void createTip({
    required String title,
    required String description,
    required TipCategory category,
  }) async {
    final result = await _communityBoardService.createTip(
      userId: 'current_user', // In real app, get from auth service
      title: title,
      description: description,
      category: category,
    );

    result.fold(
      (failure) => emit(CommunityBoardError(failure.message)),
      (newTip) {
        // Refresh the tips list
        loadData();
      },
    );
  }

  void createEvent({
    required String title,
    required String description,
    required DateTime eventDate,
    required String location,
    int? maxAttendees,
  }) async {
    final result = await _communityBoardService.createEvent(
      userId: 'current_user', // In real app, get from auth service
      title: title,
      description: description,
      eventDate: eventDate,
      location: location,
      maxAttendees: maxAttendees,
    );

    result.fold(
      (failure) => emit(CommunityBoardError(failure.message)),
      (newEvent) {
        // Refresh the events list
        loadData();
      },
    );
  }

  void reportTip(String tipId, String reason) async {
    final result = await _communityBoardService.reportTip(
      tipId: tipId,
      userId: 'current_user', // In real app, get from auth service
      reason: reason,
    );

    result.fold(
      (failure) => emit(CommunityBoardError(failure.message)),
      (success) {
        // Show success message and refresh
        loadData();
      },
    );
  }
} 