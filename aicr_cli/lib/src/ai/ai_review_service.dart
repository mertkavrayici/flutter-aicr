import '../report/aicr_report.dart';
import 'ai.dart';

abstract interface class AiReviewService {
  Future<AiReview> generate({
    required String diffText,
    required AicrReport report,
    required AiLanguage language,
  });
}
