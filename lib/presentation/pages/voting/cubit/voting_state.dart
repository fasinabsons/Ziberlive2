import 'package:equatable/equatable.dart';
import '../../../../domain/entities/vote.dart';

abstract class VotingState extends Equatable {
  const VotingState();

  @override
  List<Object?> get props => [];
}

class VotingInitial extends VotingState {}

class VotingLoading extends VotingState {}

class VotesLoaded extends VotingState {
  final List<Vote> votes;

  const VotesLoaded(this.votes);

  @override
  List<Object?> get props => [votes];
}

class VotesUpdated extends VotingState {
  final List<Vote> votes;

  const VotesUpdated(this.votes);

  @override
  List<Object?> get props => [votes];
}

class VoteCreated extends VotingState {
  final Vote vote;

  const VoteCreated(this.vote);

  @override
  List<Object?> get props => [vote];
}

class VoteCast extends VotingState {
  final UserVote userVote;

  const VoteCast(this.userVote);

  @override
  List<Object?> get props => [userVote];
}

class VoteChanged extends VotingState {}

class VoteRemoved extends VotingState {}

class VoteStoredOffline extends VotingState {}

class OfflineVotesSynced extends VotingState {
  final int syncedCount;
  final int conflictCount;

  const OfflineVotesSynced(this.syncedCount, this.conflictCount);

  @override
  List<Object?> get props => [syncedCount, conflictCount];
}

class VoteConflictsFound extends VotingState {
  final List<dynamic> conflicts; // VoteConflict from offline service

  const VoteConflictsFound(this.conflicts);

  @override
  List<Object?> get props => [conflicts];
}

class LiveVoteUpdate extends VotingState {
  final Vote vote;
  final int newVoteCount;

  const LiveVoteUpdate(this.vote, this.newVoteCount);

  @override
  List<Object?> get props => [vote, newVoteCount];
}

class FomoAlert extends VotingState {
  final Vote vote;
  final String message;

  const FomoAlert(this.vote, this.message);

  @override
  List<Object?> get props => [vote, message];
}

class VotingError extends VotingState {
  final String message;

  const VotingError(this.message);

  @override
  List<Object?> get props => [message];
}