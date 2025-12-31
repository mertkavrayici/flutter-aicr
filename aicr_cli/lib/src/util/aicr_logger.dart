import 'dart:io';

/// Tiny logger abstraction used to avoid leaking sensitive data.
///
/// - Default is no-op (library-friendly).
/// - CLI can pass `StderrAicrLogger(verbose: ...)`.
abstract class AicrLogger {
  const AicrLogger();

  bool get verbose;

  void info(String message);
  void warn(String message);
  void debug(String message);

  const factory AicrLogger.none() = _NoopAicrLogger;
}

final class _NoopAicrLogger implements AicrLogger {
  @override
  final bool verbose = false;

  const _NoopAicrLogger();

  @override
  void info(String message) {}

  @override
  void warn(String message) {}

  @override
  void debug(String message) {}
}

/// Logs to stderr to keep stdout clean for JSON / PR-comment output.
final class StderrAicrLogger implements AicrLogger {
  @override
  final bool verbose;

  const StderrAicrLogger({this.verbose = false});

  @override
  void info(String message) {
    stderr.writeln(message);
  }

  @override
  void warn(String message) {
    if (!verbose) return;
    stderr.writeln('AICR WARN: $message');
  }

  @override
  void debug(String message) {
    if (!verbose) return;
    stderr.writeln('AICR DEBUG: $message');
  }
}



