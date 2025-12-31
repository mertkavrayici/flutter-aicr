// Barrel export file for AI module
// All AI-related classes and models are exported from here

// Models (Freezed)
export 'models/ai_review.dart';

// Core interfaces
export 'ai_mode.dart';
export 'ai_reviewer.dart';
export 'ai_reviewer_factory.dart';
export 'ai_review_service.dart';
export 'ai_review_request.dart';
export 'ai_review_result.dart';
export 'ai_prompt_builder.dart';
export 'diff_redactor.dart';
export 'diff_truncator.dart';

// Legacy (kept for now; may be removed in a later sprint)
export 'ai_review_input.dart';

// Implementations
export 'ai_review_mapper.dart';
export 'deterministic_ai_review_service.dart';
export 'fake_ai_reviewer.dart';
export 'openai_ai_reviewer.dart';
export 'noop_ai_reviewer.dart';
