import 'ai_mode.dart';
import 'ai_reviewer.dart';
import 'fake_ai_reviewer.dart';
import 'noop_ai_reviewer.dart';
import 'openai_ai_reviewer.dart';
import '../util/aicr_logger.dart';
import '../profile/aicr_project_profile.dart';

/// Central place to select an `AiReviewer` implementation based on `AiMode`.
///
/// Important: do NOT silently fall back to noop for `openai`. If the key is
/// missing/invalid, `OpenAiAiReviewer` will return `AiReviewResult.error(...)`.
final class AiReviewerFactory {
  const AiReviewerFactory();

  AiReviewer create(
    AiMode mode, {
    AicrLogger logger = const AicrLogger.none(),
    AicrProjectProfile projectProfile = AicrProjectProfile.empty,
  }) => switch (mode) {
    AiMode.noop => const NoopAiReviewer(),
    AiMode.fake => const FakeAiReviewer(),
    AiMode.openai => OpenAiAiReviewer(logger: logger, projectProfile: projectProfile),
  };
}


