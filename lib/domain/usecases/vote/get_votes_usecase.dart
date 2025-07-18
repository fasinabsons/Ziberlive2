import 'package:dartz/dartz.dart';
import '../../entities/vote.dart';
import '../../repositories/vote_repository.dart';
import '../../../core/error/failures.dart';

class GetVotesUseCase {
  final VoteRepository repository;

  GetVotesUseCase(this.repository);

  Future<Either<Failure, List<Vote>>> call(String apartmentId) async {
    try {
      final result = await repository.getVotesByApartment(apartmentId);
      return result.fold(
        (failure) => Left(failure),
        (votes) {
          // Sort votes by creation date (most recent first)
          final sortedVotes = List<Vote>.from(votes);
          sortedVotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return Right(sortedVotes);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get votes: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<Vote>>> getActiveVotes(String apartmentId) async {
    try {
      final result = await repository.getActiveVotes(apartmentId);
      return result.fold(
        (failure) => Left(failure),
        (votes) {
          // Sort by deadline (most urgent first)
          final sortedVotes = List<Vote>.from(votes);
          sortedVotes.sort((a, b) => a.deadline.compareTo(b.deadline));
          return Right(sortedVotes);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get active votes: ${e.toString()}'));
    }
  }

  Future<Either<Failure, Vote>> getVoteById(String voteId) async {
    try {
      final result = await repository.getVoteById(voteId);
      return result;
    } catch (e) {
      return Left(ServerFailure('Failed to get vote: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<Vote>>> getVotesByStatus(
    String apartmentId,
    VoteStatus status,
  ) async {
    try {
      final result = await repository.getVotesByStatus(apartmentId, status);
      return result.fold(
        (failure) => Left(failure),
        (votes) {
          // Sort by creation date
          final sortedVotes = List<Vote>.from(votes);
          sortedVotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return Right(sortedVotes);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get votes by status: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<Vote>>> getExpiredVotes(String apartmentId) async {
    try {
      final result = await repository.getExpiredVotes(apartmentId);
      return result.fold(
        (failure) => Left(failure),
        (votes) {
          // Sort by deadline (most recently expired first)
          final sortedVotes = List<Vote>.from(votes);
          sortedVotes.sort((a, b) => b.deadline.compareTo(a.deadline));
          return Right(sortedVotes);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get expired votes: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<Vote>>> getVoteHistory(
    String apartmentId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final result = await repository.getVoteHistory(apartmentId, startDate, endDate);
      return result.fold(
        (failure) => Left(failure),
        (votes) {
          // Sort by creation date (most recent first)
          final sortedVotes = List<Vote>.from(votes);
          sortedVotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return Right(sortedVotes);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get vote history: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<Vote>>> getMyVotes(String apartmentId, String userId) async {
    try {
      final result = await repository.getVotesByApartment(apartmentId);
      return result.fold(
        (failure) => Left(failure),
        (votes) {
          // Filter votes where user has participated
          final myVotes = votes.where((vote) => vote.votes.containsKey(userId)).toList();
          
          // Sort by voting date (most recent first)
          myVotes.sort((a, b) {
            final aVoteDate = a.votes[userId]?.votedAt ?? a.createdAt;
            final bVoteDate = b.votes[userId]?.votedAt ?? b.createdAt;
            return bVoteDate.compareTo(aVoteDate);
          });
          
          return Right(myVotes);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get user votes: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<Vote>>> getUrgentVotes(String apartmentId) async {
    try {
      final result = await repository.getActiveVotes(apartmentId);
      return result.fold(
        (failure) => Left(failure),
        (votes) {
          final now = DateTime.now();
          
          // Filter votes that are closing within 24 hours
          final urgentVotes = votes.where((vote) {
            final timeRemaining = vote.deadline.difference(now);
            return timeRemaining.inHours <= 24 && timeRemaining.inMinutes > 0;
          }).toList();
          
          // Sort by deadline (most urgent first)
          urgentVotes.sort((a, b) => a.deadline.compareTo(b.deadline));
          
          return Right(urgentVotes);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get urgent votes: ${e.toString()}'));
    }
  }

  Future<Either<Failure, Map<String, int>>> getVoteResults(String voteId) async {
    try {
      final result = await repository.getVoteResults(voteId);
      return result;
    } catch (e) {
      return Left(ServerFailure('Failed to get vote results: ${e.toString()}'));
    }
  }

  Future<Either<Failure, UserVote?>> getUserVote(String voteId, String userId) async {
    try {
      final result = await repository.getUserVote(voteId, userId);
      return result;
    } catch (e) {
      return Left(ServerFailure('Failed to get user vote: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<VoteTemplate>>> getVoteTemplates() async {
    try {
      final result = await repository.getVoteTemplates();
      return result.fold(
        (failure) => Left(failure),
        (templates) {
          // Sort templates by name
          final sortedTemplates = List<VoteTemplate>.from(templates);
          sortedTemplates.sort((a, b) => a.name.compareTo(b.name));
          return Right(sortedTemplates);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get vote templates: ${e.toString()}'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getVoteAnalytics(String voteId) async {
    try {
      final result = await repository.getVoteAnalytics(voteId);
      return result;
    } catch (e) {
      return Left(ServerFailure('Failed to get vote analytics: ${e.toString()}'));
    }
  }
}