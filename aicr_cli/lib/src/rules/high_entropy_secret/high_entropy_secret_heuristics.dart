part of '../high_entropy_secret_rule.dart';

// ----------------------------
// entropy/heuristics: false-positive filters + entropy checks
// ----------------------------

// Magic numbers extracted
const double _minEntropyRatio = 0.3;
const double _highEntropyRatio = 0.5;

final RegExp _uuidRegex = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  caseSensitive: false,
);

final RegExp _hexHashRegex = RegExp(r'^[0-9a-f]{32,}$', caseSensitive: false);

final RegExp _secretContextRegex = RegExp(
  r'\b(secret|token|key|password|api[_-]?key)\b',
);

final RegExp _secretContextExtendedRegex = RegExp(
  r'\b(secret|token|key|password|api[_-]?key|auth|credential)\b',
);

final RegExp _hasLetterRegex = RegExp(r'[A-Za-z]');
final RegExp _hasDigitRegex = RegExp(r'\d');

/// Injectable heuristics for `HighEntropySecretRule`.
///
/// Defaults match the rule's current behavior; callers may provide a custom
/// instance via `HighEntropySecretRule(heuristics: ...)`.
final class SecretHeuristics {
  const SecretHeuristics();

  bool isLikelySecret(String value, String context) {
    // Skip if it's clearly a data URL or image data
    final ctx = context.toLowerCase();
    if (ctx.contains('data:image/') ||
        ctx.contains('data:application/') ||
        (ctx.contains('base64,') && ctx.contains('data:'))) {
      return false;
    }

    // Skip UUID
    if (_uuidRegex.hasMatch(value)) return false;

    // Skip hash unless secret-like context
    if (_hexHashRegex.hasMatch(value) && value.length % 2 == 0) {
      if (!ctx.contains(_secretContextRegex)) {
        return false;
      }
    }

    // Entropy heuristic
    final uniqueChars = value.split('').toSet().length;
    final entropyRatio = uniqueChars / value.length;
    if (entropyRatio < _minEntropyRatio) return false;

    // Context keywords shortcut
    if (ctx.contains(_secretContextExtendedRegex)) {
      return true;
    }

    // Reduce false positives: require both letters and digits when no context keywords
    final hasLetter = _hasLetterRegex.hasMatch(value);
    final hasDigit = _hasDigitRegex.hasMatch(value);
    if (!(hasLetter && hasDigit)) return false;

    return entropyRatio > _highEntropyRatio;
  }
}
