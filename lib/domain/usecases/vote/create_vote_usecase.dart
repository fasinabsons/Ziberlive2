import 'package:dartz/dartz.dart';
import '../../entities/vote.dart';
import '../../repositories/vote_repository.dart';
import '../../../core/error/failures.dart';

class CreateVoteUseCase {
  final VoteRepository repository;

  CreateVoteUseCase(this.repository);

  Future<Either<Failure, Vote>> call(Vote vote) async {
    try {
      // Validate vote data
      if (vote.question.trim().isEmpty) {
        return Left(ValidationFailure('Vote question cannot be empty'));
      }
      
      if (vote.options.isEmpty) {
        return Left(ValidationFailure('Vote must have at least one option'));
      }
      
      if (vote.deadline.isBefore(DateTime.now())) {
        return Left(ValidationFailure('Vote deadline cannot be in the past'));
      }
      
      // Validate options
      if (vote.type == VoteType.yesNo && vote.options.length != 2) {
        return Left(ValidationFailure('Yes/No votes must have exactly 2 options'));
      }
      
      if (vote.options.length > 10) {
        return Left(ValidationFailure('Vote cannot have more than 10 options'));
      }
      
      // Check for duplicate option texts
      final optionTexts = vote.options.map((option) => option.text.toLowerCase()).toList();
      final uniqueTexts = optionTexts.toSet();
      if (optionTexts.length != uniqueTexts.length) {
        return Left(ValidationFailure('Vote options must be unique'));
      }

      // Create the vote
      final result = await repository.createVote(vote);
      return result.fold(
        (failure) => Left(failure),
        (createdVote) {
          // TODO: Send notifications to apartment members
          _sendVoteCreationNotifications(createdVote);
          return Right(createdVote);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to create vote: ${e.toString()}'));
    }
  }

  Future<Either<Failure, Vote>> createFromTemplate(
    String templateId,
    String apartmentId,
    String createdBy,
    DateTime deadline, {
    String? customQuestion,
    String? customDescription,
    bool? isAnonymous,
    bool? allowComments,
  }) async {
    try {
      if (deadline.isBefore(DateTime.now())) {
        return Left(ValidationFailure('Vote deadline cannot be in the past'));
      }

      final customizations = <String, dynamic>{};
      if (customQuestion != null) customizations['question'] = customQuestion;
      if (customDescription != null) customizations['description'] = customDescription;
      if (isAnonymous != null) customizations['isAnonymous'] = isAnonymous;
      if (allowComments != null) customizations['allowComments'] = allowComments;

      final result = await repository.createVoteFromTemplate(
        templateId,
        apartmentId,
        createdBy,
        deadline,
        customizations: customizations,
      );
      
      return result.fold(
        (failure) => Left(failure),
        (vote) {
          _sendVoteCreationNotifications(vote);
          return Right(vote);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to create vote from template: ${e.toString()}'));
    }
  }

  Future<Either<Failure, Vote>> createQuickPoll(
    String question,
    List<String> options,
    String apartmentId,
    String createdBy, {
    Duration duration = const Duration(hours: 24),
    bool isAnonymous = false,
  }) async {
    try {
      if (options.length < 2) {
        return Left(ValidationFailure('Quick poll must have at least 2 options'));
      }

      final voteOptions = options.asMap().entries.map((entry) {
        return VoteOption(
          id: 'option_${entry.key}',
          text: entry.value,
          order: entry.key,
        );
      }).toList();

      final vote = Vote(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        question: question,
        description: 'Quick poll created for immediate decision',
        type: VoteType.singleChoice,
        options: voteOptions,
        apartmentId: apartmentId,
        createdBy: createdBy,
        deadline: DateTime.now().add(duration),
        isAnonymous: isAnonymous,
        allowComments: true,
        votes: {},
        status: VoteStatus.active,
        createdAt: DateTime.now(),
        metadata: {'is_quick_poll': true},
      );

      return await call(vote);
    } catch (e) {
      return Left(ServerFailure('Failed to create quick poll: ${e.toString()}'));
    }
  }

  void _sendVoteCreationNotifications(Vote vote) {
    // TODO: Implement notification service
    print('Notification: New vote created: "${vote.question}"');
    print('Deadline: ${vote.deadline}');
    
    // Send FOMO alerts based on deadline proximity
    final timeUntilDeadline = vote.deadline.difference(DateTime.now());
    if (timeUntilDeadline.inHours <= 24) {
      print('URGENT: Vote closes in ${timeUntilDeadline.inHours} hours!');
    }
  }
}