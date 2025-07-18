import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/vote.dart';
import '../../../../domain/usecases/vote/create_vote_usecase.dart';
import '../../../../domain/usecases/vote/cast_vote_usecase.dart';
import '../../../../domain/usecases/vote/get_votes_usecase.dart';
import '../../../../core/services/offline_vote_service.dart';
import '../../../../core/services/data_sync_service.dart';
import 'voting_state.dart';
import 'dart:async';

class VotingCubit extends Cubit<VotingState> {
  final CreateVoteUseCase _createVoteUseCase;
  final CastVoteUseCase _castVoteUseCase;
  final GetVotesUseCase _getVotesUseCase;
  final OfflineVoteService _offlineVoteService;
  final DataSyncService _syncService;
  
  Timer? _liveUpdateTimer;
  Timer? _fomoAlertTimer;

  VotingCubit({
    required CreateVoteUseCase createVoteUseCase,
    required CastVoteUseCase castVoteUseCase,
    required GetVotesUseCase getVotesUseCase,
    required OfflineVoteService offlineVoteService,
    required DataSyncService syncService,
  })  : _createVoteUseCase = createVoteUseCase,
        _castVoteUseCase = castVoteUseCase,
        _getVotesUseCase = getVotesUseCase,
        _offlineVoteService = offlineVoteService,
        _syncService = syncService,
        super(VotingInitial());

  @override
  Future<void> close() {
    _liveUpdateTimer?.cancel();
    _fomoAlertTimer?.cancel();
    return super.close();
  }

  Future<void> loadVotes({String? apartmentId}) async {
    emit(VotingLoading());
    try {
      final result = await _getVotesUseCase(apartmentId ?? 'current_apartment');
      result.fold(
        (failure) => emit(VotingError(failure.message)),
        (votes) {
          emit(VotesLoaded(votes));
          _startLiveUpdates();
          _scheduleFomoAlerts(votes);
        },
      );
    } catch (e) {
      emit(VotingError('Failed to load votes: ${e.toString()}'));
    }
  }

  Future<void> createVote(Vote vote) async {
    emit(VotingLoading());
    try {
      final result = await _createVoteUseCase(vote);
      result.fold(
        (failure) => emit(VotingError(failure.message)),
        (createdVote) {
          emit(VoteCreated(createdVote));
          loadVotes(); // Refresh the list
        },
      );
    } catch (e) {
      emit(VotingError('Failed to create vote: ${e.toString()}'));
    }
  }

  Future<void> createQuickPoll(
    String question,
    List<String> options,
    String apartmentId,
    String createdBy,
  ) async {
    emit(VotingLoading());
    try {
      final result = await _createVoteUseCase.createQuickPoll(
        question,
        options,
        apartmentId,
        createdBy,
      );
      result.fold(
        (failure) => emit(VotingError(failure.message)),
        (vote) {
          emit(VoteCreated(vote));
          loadVotes(); // Refresh the list
        },
      );
    } catch (e) {
      emit(VotingError('Failed to create quick poll: ${e.toString()}'));
    }
  }

  Future<void> castVote(
    String voteId,
    String userId,
    List<String> selectedOptionIds, {
    String? comment,
    int? rating,
  }) async {
    emit(VotingLoading());
    try {
      // Check if we're online
      final isOnline = await _syncService.isOnline();
      
      if (isOnline) {
        // Cast vote online
        final result = await _castVoteUseCase(
          voteId,
          userId,
          selectedOptionIds,
          comment: comment,
          rating: rating,
        );
        result.fold(
          (failure) => emit(VotingError(failure.message)),
          (userVote) {
            emit(VoteCast(userVote));
            loadVotes(); // Refresh to show updated counts
          },
        );
      } else {
        // Store vote offline
        final offlineResult = await _offlineVoteService.storeOfflineVote(
          voteId,
          userId,
          selectedOptionIds,
          comment: comment,
          rating: rating,
        );
        
        offlineResult.fold(
          (failure) => emit(VotingError(failure.message)),
          (_) {
            emit(VoteStoredOffline());
            loadVotes(); // Refresh to show pending status
          },
        );
      }
    } catch (e) {
      emit(VotingError('Failed to cast vote: ${e.toString()}'));
    }
  }

  Future<void> changeVote(
    String voteId,
    String userId,
    List<String> selectedOptionIds, {
    String? comment,
    int? rating,
  }) async {
    emit(VotingLoading());
    try {
      final result = await _castVoteUseCase.changeVote(
        voteId,
        userId,
        selectedOptionIds,
        newComment: comment,
        newRating: rating,
      );
      result.fold(
        (failure) => emit(VotingError(failure.message)),
        (_) {
          emit(VoteChanged());
          loadVotes(); // Refresh to show updated counts
        },
      );
    } catch (e) {
      emit(VotingError('Failed to change vote: ${e.toString()}'));
    }
  }

  Future<void> removeVote(String voteId, String userId) async {
    emit(VotingLoading());
    try {
      final result = await _castVoteUseCase.removeVote(voteId, userId);
      result.fold(
        (failure) => emit(VotingError(failure.message)),
        (_) {
          emit(VoteRemoved());
          loadVotes(); // Refresh to show updated counts
        },
      );
    } catch (e) {
      emit(VotingError('Failed to remove vote: ${e.toString()}'));
    }
  }

  Future<void> getActiveVotes({String? apartmentId}) async {
    emit(VotingLoading());
    try {
      final result = await _getVotesUseCase.getActiveVotes(apartmentId ?? 'current_apartment');
      result.fold(
        (failure) => emit(VotingError(failure.message)),
        (votes) {
          emit(VotesLoaded(votes));
          _startLiveUpdates();
          _scheduleFomoAlerts(votes);
        },
      );
    } catch (e) {
      emit(VotingError('Failed to load active votes: ${e.toString()}'));
    }
  }

  Future<void> getVoteHistory({String? apartmentId}) async {
    emit(VotingLoading());
    try {
      final result = await _getVotesUseCase.getVoteHistory(
        apartmentId ?? 'current_apartment',
        DateTime.now().subtract(const Duration(days: 30)),
        DateTime.now(),
      );
      result.fold(
        (failure) => emit(VotingError(failure.message)),
        (votes) => emit(VotesLoaded(votes)),
      );
    } catch (e) {
      emit(VotingError('Failed to load vote history: ${e.toString()}'));
    }
  }

  void _startLiveUpdates() {
    _liveUpdateTimer?.cancel();
    _liveUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      // Refresh vote counts every 30 seconds for live updates
      if (state is VotesLoaded) {
        _refreshVoteCounts();
      }
    });
  }

  Future<void> _refreshVoteCounts() async {
    try {
      final result = await _getVotesUseCase('current_apartment');
      result.fold(
        (failure) => null, // Silently fail for background updates
        (votes) {
          if (state is VotesLoaded) {
            final currentState = state as VotesLoaded;
            // Only emit if there are actual changes
            if (_hasVoteCountChanges(currentState.votes, votes)) {
              emit(VotesUpdated(votes));
            }
          }
        },
      );
    } catch (e) {
      // Silently handle errors for background updates
    }
  }

  bool _hasVoteCountChanges(List<Vote> oldVotes, List<Vote> newVotes) {
    if (oldVotes.length != newVotes.length) return true;
    
    for (int i = 0; i < oldVotes.length; i++) {
      if (oldVotes[i].totalVotes != newVotes[i].totalVotes) {
        return true;
      }
    }
    return false;
  }

  void _scheduleFomoAlerts(List<Vote> votes) {
    _fomoAlertTimer?.cancel();
    
    final activeVotes = votes.where((vote) => vote.isActive).toList();
    if (activeVotes.isEmpty) return;

    // Find the next vote that needs a FOMO alert
    Vote? nextAlertVote;
    Duration? nextAlertDelay;

    for (final vote in activeVotes) {
      final timeRemaining = vote.timeRemaining;
      
      // Schedule alerts for 1 hour, 6 hours, and 24 hours before deadline
      final alertTimes = [
        const Duration(hours: 1),
        const Duration(hours: 6),
        const Duration(hours: 24),
      ];

      for (final alertTime in alertTimes) {
        if (timeRemaining > alertTime) {
          final delay = timeRemaining - alertTime;
          if (nextAlertDelay == null || delay < nextAlertDelay) {
            nextAlertDelay = delay;
            nextAlertVote = vote;
          }
        }
      }
    }

    if (nextAlertVote != null && nextAlertDelay != null) {
      _fomoAlertTimer = Timer(nextAlertDelay, () {
        _sendFomoAlert(nextAlertVote!);
        _scheduleFomoAlerts(votes); // Schedule next alert
      });
    }
  }

  void _sendFomoAlert(Vote vote) {
    final timeRemaining = vote.timeRemaining;
    String alertMessage;

    if (timeRemaining.inHours <= 1) {
      alertMessage = 'URGENT: Poll "${vote.question}" closes in ${timeRemaining.inMinutes} minutes!';
    } else if (timeRemaining.inHours <= 6) {
      alertMessage = 'Poll "${vote.question}" closes in ${timeRemaining.inHours} hours!';
    } else {
      alertMessage = 'Reminder: Poll "${vote.question}" closes in ${timeRemaining.inHours} hours';
    }

    emit(FomoAlert(vote, alertMessage));
    
    // Return to previous state after showing alert
    Timer(const Duration(seconds: 3), () {
      loadVotes();
    });
  }

  void showLiveVoteUpdate(Vote vote, int newVoteCount) {
    emit(LiveVoteUpdate(vote, newVoteCount));
    
    // Return to previous state after showing update
    Timer(const Duration(seconds: 2), () {
      if (state is VotesLoaded) {
        final currentState = state as VotesLoaded;
        emit(VotesLoaded(currentState.votes));
      }
    });
  }

  void dismissAlert() {
    if (state is FomoAlert) {
      loadVotes();
    }
  }

  Future<void> syncOfflineVotes() async {
    emit(VotingLoading());
    try {
      final result = await _offlineVoteService.syncOfflineVotes();
      result.fold(
        (failure) {
          if (failure is ConflictFailure) {
            _loadVoteConflicts();
          } else {
            emit(VotingError(failure.message));
          }
        },
        (_) {
          emit(const OfflineVotesSynced(0, 0)); // TODO: Get actual counts
          loadVotes(); // Refresh to show synced votes
        },
      );
    } catch (e) {
      emit(VotingError('Failed to sync offline votes: ${e.toString()}'));
    }
  }

  Future<void> _loadVoteConflicts() async {
    try {
      final result = await _offlineVoteService.getVoteConflicts();
      result.fold(
        (failure) => emit(VotingError(failure.message)),
        (conflicts) => emit(VoteConflictsFound(conflicts)),
      );
    } catch (e) {
      emit(VotingError('Failed to load vote conflicts: ${e.toString()}'));
    }
  }

  Future<void> resolveVoteConflict(String conflictId, dynamic conflict) async {
    emit(VotingLoading());
    try {
      final result = await _offlineVoteService.resolveVoteConflict(conflictId, conflict);
      result.fold(
        (failure) => emit(VotingError(failure.message)),
        (_) {
          // Check if there are more conflicts
          _loadVoteConflicts();
        },
      );
    } catch (e) {
      emit(VotingError('Failed to resolve vote conflict: ${e.toString()}'));
    }
  }

  Future<void> getPendingOfflineVotes() async {
    try {
      final result = await _offlineVoteService.getPendingVotes();
      result.fold(
        (failure) => emit(VotingError(failure.message)),
        (pendingVotes) {
          if (pendingVotes.isNotEmpty) {
            emit(VoteStoredOffline());
          }
        },
      );
    } catch (e) {
      emit(VotingError('Failed to get pending votes: ${e.toString()}'));
    }
  }

  Future<void> retryFailedVotes() async {
    await syncOfflineVotes();
  }
}