import '../util/aicr_logger.dart';

/// Repository information for posting comments.
final class RepoInfo {
  final String owner;
  final String name;

  const RepoInfo({required this.owner, required this.name});

  /// Creates from full repo name (e.g., "owner/repo").
  factory RepoInfo.fromFullName(String fullName) {
    final parts = fullName.split('/');
    if (parts.length != 2) {
      throw ArgumentError('Invalid repo format: $fullName (expected owner/repo)');
    }
    return RepoInfo(owner: parts[0], name: parts[1]);
  }

  String get fullName => '$owner/$name';
}

/// Result of posting a comment.
sealed class CommentPostResult {
  const CommentPostResult();
}

final class CommentPostSuccess extends CommentPostResult {
  final bool wasUpdated;

  const CommentPostSuccess({required this.wasUpdated});
}

final class CommentPostFailure extends CommentPostResult {
  final String error;

  const CommentPostFailure({required this.error});
}

/// Interface for posting comments to code review platforms.
abstract interface class CommentPoster {
  /// Posts a comment to the specified PR/MR.
  ///
  /// If a comment with the same diff hash marker exists, it will be updated.
  /// Otherwise, a new comment will be created.
  ///
  /// Returns [CommentPostSuccess] on success, [CommentPostFailure] on failure.
  /// Failures are logged as warnings and do not throw exceptions.
  Future<CommentPostResult> post({
    required RepoInfo repo,
    required int prOrMrNumber,
    required String body,
    required String diffHash,
    required String token,
    AicrLogger? logger,
  });
}


