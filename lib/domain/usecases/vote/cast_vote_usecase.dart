import 'package:dartz/dartz.dart';
import '../../entities/vote.dart';
import '../../entities/gamification.dart';
import '../../repositories/vote_repository.dart';
import '../../../core/error/failures.dart';
import '../../../core/services/gamification_service.dart';

class CastVoteUseCase {
  final VoteRepository repository;
  final GamificationService gamificationService;

  CastVoteUseCase(this.repository, this.gamificationService);

  Future<Either<Failure, UserVote>> call(
    String voteId,
    String userId,
    List<String> selectedOptionIds, {
    String? comment,
    int? rating,
  }) async {
    try {
      // Get the vote to validate
      final voteResult = await repository.getVoteById(voteId);
      return voteResult.fold(
        (failure) => Left(failure),
        (vote) async {
          // Validate voting eligibility
          final validationResult = _validateVote(vote, userId, selectedOptionIds, rating);
          if (validationResult != null) {
            return Left(validationResult);
          }

          // Check if user has already voted
          final existingVoteResult = await repository.getUserVote(voteId, userId);
          return existingVoteResult.fold(
            (failure) => Left(failure),
            (existingVote) async {
              if (existingVote != null) {
                return Left(ValidationFailure('User has already voted on this poll'));
              }

              // Cast the vote
              final castResult = await repository.castVote(
                voteId,
                userId,
                selectedOptionIds,
                comment: comment,
                rating: rating,
              );

              return castResult.fold(
                (failure) => Left(failure),
                (userVote) async {
                  // Award credits for voting participation
                  await _awardVotingCredits(userId, vote);
                  
                  // Send notifications
                  _sendVotingNotifications(vote, userVote);
                  
                  return Right(userVote);
                },
              );
            },
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to cast vote: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> changeVote(
    String voteId,
    String userId,
    List<String> newSelectedOptionIds, {
    String? newComment,
    int? newRating,
  }) async {
    try {
      // Get the vote to validate
      final voteResult = await repository.getVoteById(voteId);
      return voteResult.fold(
        (failure) => Left(failure),
        (vote) async {
          // Check if vote allows changes (before deadline and still active)
          if (!vote.isActive) {
            return Left(ValidationFailure('Cannot change vote on inactive poll'));
          }

          // Validate new vote options
          final validationResult = _validateVote(vote, userId, newSelectedOptionIds, newRating);
          if (validationResult != null) {
            return Left(validationResult);
          }

          // Remove existing vote and cast new one
          await repository.removeVote(voteId, userId);
          
          final castResult = await repository.castVote(
            voteId,
            userId,
            newSelectedOptionIds,
            comment: newComment,
            rating: newRating,
          );

          return castResult.fold(
            (failure) => Left(failure),
            (_) {
              print('Vote changed for user $userId on poll: ${vote.question}');
              return const Right(null);
            },
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to change vote: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> removeVote(String voteId, String userId) async {
    try {
      final voteResult = await repository.getVoteById(voteId);
      return voteResult.fold(
        (failure) => Left(failure),
        (vote) async {
          if (!vote.isActive) {
            return Left(ValidationFailure('Cannot remove vote from inactive poll'));
          }

          final result = await repository.removeVote(voteId, userId);
          return result.fold(
            (failure) => Left(failure),
            (_) {
              print('Vote removed for user $userId on poll: ${vote.question}');
              return const Right(null);
            },
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to remove vote: ${e.toString()}'));
    }
  }

  ValidationFailure? _validateVote(
    Vote vote,
    String userId,
    List<String> selectedOptionIds,
    int? rating,
  ) {
    // Check if vote is still active
    if (!vote.isActive) {
      return ValidationFailure('This poll is no longer active');
    }

    // Check if vote has expired
    if (vote.isExpired) {
      return ValidationFailure('This poll has expired');
    }

    // Validate selected options
    if (selectedOptionIds.isEmpty) {
      return ValidationFailure('At least one option must be selected');
    }

    // Check if all selected options exist
    final validOptionIds = vote.options.map((option) => option.id).toSet();
    for (final optionId in selectedOptionIds) {
      if (!validOptionIds.contains(optionId)) {
        return ValidationFailure('Invalid option selected');
      }
    }

    // Validate based on vote type
    switch (vote.type) {
      case VoteType.singleChoice:
      case VoteType.yesNo:
        if (selectedOptionIds.length != 1) {
          return ValidationFailure('Only one option can be selected for this vote type');
        }
        break;
      case VoteType.multipleChoice:
        if (selectedOptionIds.length > vote.options.length) {
          return ValidationFailure('Too many options selected');
        }
        break;
      case VoteType.rating:
        if (rating == null || rating < 1 || rating > 5) {
          return ValidationFailure('Rating must be between 1 and 5');
        }
        break;
    }

    return null;
  }

  Future<void> _awardVotingCredits(String userId, Vote vote) async {
    // Award credits for voting participation
    await gamificationService.awardCredits(
      userId,
      3, // 3 credits per vote as specified in requirements
      CreditReason.voting,
      description: 'Voted on: ${vote.question}',
      relatedEntityId: vote.id,
    );
  }

  void _sendVotingNotifications(Vote vote, UserVote userVote) {
    // TODO: Implement notification service
    print('Vote cast by ${userVote.userId} on poll: ${vote.question}');
    
    // Send progress updates
    final currentVotes = vote.totalVotes + 1; // +1 for the new vote
    final totalEligible = vote.totalEligibleVoters;
    print('Progress: $currentVotes/$totalEligible voted');
    
    // Send FOMO alerts if deadline is approaching
    final timeRemaining = vote.timeRemaining;
    if (timeRemaining.inHours <= 6 && timeRemaining.inHours > 0) {
      print('FOMO Alert: Poll closes in ${timeRemaining.inHours} hours!');
    } else if (timeRemaining.inMinutes <= 60 && timeRemaining.inMinutes > 0) {
      print('URGENT: Poll closes in ${timeRemaining.inMinutes} minutes!');
    }
  }
}