part of '../high_entropy_secret_rule.dart';

// ----------------------------
// ignore politikası: rule-specific default ignores (hardcode)
// ----------------------------

/// Injectable ignore policy for `HighEntropySecretRule`.
///
/// Defaults match the rule's current behavior; callers may provide a custom
/// instance via `HighEntropySecretRule(ignorePolicy: ...)`.
final class IgnorePolicy {
  const IgnorePolicy();

  bool isIgnored(String filePath) {
    final p = filePath.replaceAll('\\', '/').toLowerCase().trim();
    if (p.endsWith('.g.dart')) return true;
    if (p.endsWith('.freezed.dart')) return true;
    if (p.startsWith('lib/l10n/') && p.endsWith('.arb')) return true;
    if (p.endsWith('injection.config.dart')) return true;
    return false;
  }
}


