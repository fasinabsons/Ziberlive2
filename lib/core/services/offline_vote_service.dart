import 'package:dartz/dartz.dart';
import '../../domain/entities/vote.dart';
import '../error/failures.dart';
import '../utils/result.dart';
import 'data_sync_service.dart';
import 'ad_service.dart';

abstract class OfflineVoteService {
  Future<Either<Failure, void>> storeOfflineVote(
    String voteId,
    String userId,
    List<String> selectedOptionIds, {
    String? comment,
    int? rating,
  });
  
  Future<Either<Failure, List<OfflineVote>>> getPendingVotes();
  
  Future<Either<Failure, void>> syncOfflineVotes();
  
  Future<Either<Failure, void>> resolveVoteConflict(
    String voteId,
    VoteConflict conflict,
  );
  
  Future<Either<Failure, List<VoteConflict>>> getVoteConflicts();
}

class OfflineVoteServiceImpl implements OfflineVoteService {
  final DataSyncService _syncService;
  final AdService _adService;
  
  // In-memory storage for offline votes (in real app, this would be SQLite)
  final List<OfflineVote> _pendingVotes = [];
  final List<VoteConflict> _conflicts = [];

  OfflineVoteServiceImpl({
    required DataSyncService syncService,
    required AdService adService,
  })  : _syncService = syncService,
        _adService = adService;

  @override
  Future<Either<Failure, void>> storeOfflineVote(
    String voteId,
    String userId,
    List<String> selectedOptionIds, {
    String? comment,
    int? rating,
  }) async {
    try {
      final offlineVote = OfflineVote(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        voteId: voteId,
        userId: userId,
        selectedOptionIds: selectedOptionIds,
        comment: comment,
        rating: rating,
        timestamp: DateTime.now(),
        syncStatus: SyncStatus.pending,
      );

      _pendingVotes.add(offlineVote);
      
      // TODO: Store in SQLite database
      await _storeInDatabase(offlineVote);
      
      print('Offline vote stored: ${offlineVote.id}');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to store offline vote: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<OfflineVote>>> getPendingVotes() async {
    try {
      // TODO: Load from SQLite database
      final pendingVotes = _pendingVotes
          .where((vote) => vote.syncStatus == SyncStatus.pending)
          .toList();
      
      return Right(pendingVotes);
    } catch (e) {
      return Left(ServerFailure('Failed to get pending votes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> syncOfflineVotes() async {
    try {
      final pendingResult = await getPendingVotes();
      return pendingResult.fold(
        (failure) => Left(failure),
        (pendingVotes) async {
          if (pendingVotes.isEmpty) {
            return const Right(null);
          }

          // Display 2 ads per sync operation as per requirements
          await _adService.showBannerAd();
          await _adService.showBannerAd();

          int successCount = 0;
          int conflictCount = 0;

          for (final offlineVote in pendingVotes) {
            final syncResult = await _syncSingleVote(offlineVote);
            syncResult.fold(
              (failure) {
                if (failure is ConflictFailure) {
                  conflictCount++;
                  _handleVoteConflict(offlineVote, failure);
                } else {
                  print('Failed to sync vote ${offlineVote.id}: ${failure.message}');
                }
              },
              (_) {
                successCount++;
                _markVoteAsSynced(offlineVote);
              },
            );
          }

          print('Vote sync completed: $successCount synced, $conflictCount conflicts');
          
          if (conflictCount > 0) {
            return Left(ConflictFailure('$conflictCount vote conflicts need resolution'));
          }
          
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to sync offline votes: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> _syncSingleVote(OfflineVote offlineVote) async {
    try {
      // Check if vote still exists and is active
      final voteCheckResult = await _syncService.checkVoteStatus(offlineVote.voteId);
      return voteCheckResult.fold(
        (failure) => Left(failure),
        (voteStatus) async {
          if (!voteStatus.isActive) {
            return Left(ValidationFailure('Vote is no longer active'));
          }

          // Check for existing vote by this user
          final existingVoteResult = await _syncService.getUserVote(
            offlineVote.voteId,
            offlineVote.userId,
          );

          return existingVoteResult.fold(
            (failure) => Left(failure),
            (existingVote) async {
              if (existingVote != null) {
                // Conflict: user has already voted
                return Left(ConflictFailure(
                  'User has already voted on this poll',
                  conflictData: {
                    'existing_vote': existingVote.toJson(),
                    'offline_vote': offlineVote.toJson(),
                  },
                ));
              }

              // No conflict, proceed with sync
              final syncResult = await _syncService.castVote(
                offlineVote.voteId,
                offlineVote.userId,
                offlineVote.selectedOptionIds,
                comment: offlineVote.comment,
                rating: offlineVote.rating,
              );

              return syncResult.fold(
                (failure) => Left(failure),
                (_) => const Right(null),
              );
            },
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to sync vote: ${e.toString()}'));
    }
  }

  void _handleVoteConflict(OfflineVote offlineVote, ConflictFailure failure) {
    final conflict = VoteConflict(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      offlineVote: offlineVote,
      conflictType: VoteConflictType.duplicateVote,
      conflictData: failure.conflictData ?? {},
      createdAt: DateTime.now(),
      status: ConflictStatus.pending,
    );

    _conflicts.add(conflict);
    print('Vote conflict detected: ${conflict.id}');
  }

  void _markVoteAsSynced(OfflineVote offlineVote) {
    final index = _pendingVotes.indexWhere((vote) => vote.id == offlineVote.id);
    if (index != -1) {
      _pendingVotes[index] = offlineVote.copyWith(
        syncStatus: SyncStatus.synced,
        syncedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<Either<Failure, void>> resolveVoteConflict(
    String voteId,
    VoteConflict conflict,
  ) async {
    try {
      switch (conflict.conflictType) {
        case VoteConflictType.duplicateVote:
          return await _resolveDuplicateVoteConflict(conflict);
        case VoteConflictType.voteExpired:
          return await _resolveExpiredVoteConflict(conflict);
        case VoteConflictType.optionChanged:
          return await _resolveOptionChangedConflict(conflict);
      }
    } catch (e) {
      return Left(ServerFailure('Failed to resolve vote conflict: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> _resolveDuplicateVoteConflict(VoteConflict conflict) async {
    // For duplicate votes, we typically keep the server version and discard offline
    final conflictIndex = _conflicts.indexWhere((c) => c.id == conflict.id);
    if (conflictIndex != -1) {
      _conflicts[conflictIndex] = conflict.copyWith(
        status: ConflictStatus.resolved,
        resolution: ConflictResolution.keepServer,
        resolvedAt: DateTime.now(),
      );
    }

    // Mark offline vote as discarded
    final offlineVoteIndex = _pendingVotes.indexWhere(
      (vote) => vote.id == conflict.offlineVote.id,
    );
    if (offlineVoteIndex != -1) {
      _pendingVotes[offlineVoteIndex] = conflict.offlineVote.copyWith(
        syncStatus: SyncStatus.discarded,
      );
    }

    return const Right(null);
  }

  Future<Either<Failure, void>> _resolveExpiredVoteConflict(VoteConflict conflict) async {
    // For expired votes, discard the offline vote
    final conflictIndex = _conflicts.indexWhere((c) => c.id == conflict.id);
    if (conflictIndex != -1) {
      _conflicts[conflictIndex] = conflict.copyWith(
        status: ConflictStatus.resolved,
        resolution: ConflictResolution.discard,
        resolvedAt: DateTime.now(),
      );
    }

    return const Right(null);
  }

  Future<Either<Failure, void>> _resolveOptionChangedConflict(VoteConflict conflict) async {
    // For changed options, we need user input to resolve
    // This would typically show a dialog to the user
    return Left(ValidationFailure('Option changed conflicts require user resolution'));
  }

  @override
  Future<Either<Failure, List<VoteConflict>>> getVoteConflicts() async {
    try {
      final pendingConflicts = _conflicts
          .where((conflict) => conflict.status == ConflictStatus.pending)
          .toList();
      
      return Right(pendingConflicts);
    } catch (e) {
      return Left(ServerFailure('Failed to get vote conflicts: ${e.toString()}'));
    }
  }

  Future<void> _storeInDatabase(OfflineVote vote) async {
    // TODO: Implement SQLite storage
    print('Storing offline vote in database: ${vote.id}');
  }
}

class OfflineVote {
  final String id;
  final String voteId;
  final String userId;
  final List<String> selectedOptionIds;
  final String? comment;
  final int? rating;
  final DateTime timestamp;
  final SyncStatus syncStatus;
  final DateTime? syncedAt;

  const OfflineVote({
    required this.id,
    required this.voteId,
    required this.userId,
    required this.selectedOptionIds,
    this.comment,
    this.rating,
    required this.timestamp,
    required this.syncStatus,
    this.syncedAt,
  });

  OfflineVote copyWith({
    String? id,
    String? voteId,
    String? userId,
    List<String>? selectedOptionIds,
    String? comment,
    int? rating,
    DateTime? timestamp,
    SyncStatus? syncStatus,
    DateTime? syncedAt,
  }) {
    return OfflineVote(
      id: id ?? this.id,
      voteId: voteId ?? this.voteId,
      userId: userId ?? this.userId,
      selectedOptionIds: selectedOptionIds ?? this.selectedOptionIds,
      comment: comment ?? this.comment,
      rating: rating ?? this.rating,
      timestamp: timestamp ?? this.timestamp,
      syncStatus: syncStatus ?? this.syncStatus,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vote_id': voteId,
      'user_id': userId,
      'selected_option_ids': selectedOptionIds,
      'comment': comment,
      'rating': rating,
      'timestamp': timestamp.toIso8601String(),
      'sync_status': syncStatus.toString().split('.').last,
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  factory OfflineVote.fromJson(Map<String, dynamic> json) {
    return OfflineVote(
      id: json['id'],
      voteId: json['vote_id'],
      userId: json['user_id'],
      selectedOptionIds: List<String>.from(json['selected_option_ids']),
      comment: json['comment'],
      rating: json['rating'],
      timestamp: DateTime.parse(json['timestamp']),
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['sync_status'],
      ),
      syncedAt: json['synced_at'] != null ? DateTime.parse(json['synced_at']) : null,
    );
  }
}

class VoteConflict {
  final String id;
  final OfflineVote offlineVote;
  final VoteConflictType conflictType;
  final Map<String, dynamic> conflictData;
  final DateTime createdAt;
  final ConflictStatus status;
  final ConflictResolution? resolution;
  final DateTime? resolvedAt;

  const VoteConflict({
    required this.id,
    required this.offlineVote,
    required this.conflictType,
    required this.conflictData,
    required this.createdAt,
    required this.status,
    this.resolution,
    this.resolvedAt,
  });

  VoteConflict copyWith({
    String? id,
    OfflineVote? offlineVote,
    VoteConflictType? conflictType,
    Map<String, dynamic>? conflictData,
    DateTime? createdAt,
    ConflictStatus? status,
    ConflictResolution? resolution,
    DateTime? resolvedAt,
  }) {
    return VoteConflict(
      id: id ?? this.id,
      offlineVote: offlineVote ?? this.offlineVote,
      conflictType: conflictType ?? this.conflictType,
      conflictData: conflictData ?? this.conflictData,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      resolution: resolution ?? this.resolution,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}

enum SyncStatus { pending, synced, failed, discarded }

enum VoteConflictType { duplicateVote, voteExpired, optionChanged }

enum ConflictStatus { pending, resolved, ignored }

enum ConflictResolution { keepServer, keepOffline, merge, discard }

class VoteStatus {
  final bool isActive;
  final DateTime? deadline;
  final List<String> availableOptions;

  const VoteStatus({
    required this.isActive,
    this.deadline,
    required this.availableOptions,
  });
}

class ConflictFailure extends Failure {
  final Map<String, dynamic>? conflictData;

  ConflictFailure(String message, {this.conflictData}) : super(message);
}