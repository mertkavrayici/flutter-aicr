// lib/src/ai/ai_reviewer.dart

import 'package:aicr_cli/src/finding/models/aicr_finding.dart';

import 'ai_review_input.dart';

/// AI katmanı: "karar" değil "yorum".
/// - Deterministic kurallarla çakışmaz, onları tamamlar.
/// - Her zaman empty dönebilir (AI yoksa, timeout olursa, vs.)
abstract interface class AiReviewer {
  Future<List<AicrFinding>> review(AiReviewInput input);
}
