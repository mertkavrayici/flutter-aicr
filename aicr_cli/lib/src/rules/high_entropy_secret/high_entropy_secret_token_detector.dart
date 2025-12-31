part of '../high_entropy_secret_rule.dart';

// ----------------------------
// token tespiti: AWS/JWT/base64-like/assignment/string-literal
// ----------------------------

// Magic numbers extracted
const int _minTokenLen = 20;
const int _minBase64Len = 24;

final class _TokenDetector {
  final SecretHeuristics heuristics;

  const _TokenDetector({required this.heuristics});

  static final RegExp _awsKeyPattern = RegExp(r'AKIA[0-9A-Z]{16}');
  static final RegExp _jwtPattern = RegExp(
    r'eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}',
  );

  // Base64-like: keep broad regex, but apply extra guards to reduce false positives
  static final RegExp _base64Pattern = RegExp(r'[A-Za-z0-9+/]{20,}={0,2}');

  static final RegExp _assignmentContextPattern = RegExp(
    r'[:=]\s*["'
    ']?([A-Za-z0-9+/=_.-]{20,})["'
    ']?',
    caseSensitive: false,
  );

  static final RegExp _tokenInStringPattern = RegExp(
    r'["'
    ']([A-Za-z0-9+/=_.-]{20,})["'
    ']',
  );

  List<_SecretHit> detect(List<_AddedLine> lines) {
    final out = <_SecretHit>[];

    for (final l in lines) {
      final content = l.content;

      // Skip comments/docs to reduce noise
      final trimmed = content.trimLeft();
      if (trimmed.startsWith('//') ||
          trimmed.startsWith('*') ||
          trimmed.startsWith('#')) {
        continue;
      }

      final aws = _awsKeyPattern.firstMatch(content);
      if (aws != null) {
        out.add(
          _SecretHit(
            filePath: l.filePath,
            lineNumber: l.lineNumber,
            snippet: _Snippet.makeAroundMatch(
              content,
              start: aws.start,
              end: aws.end,
              maxLen: HighEntropySecretRule._snippetMaxLen,
            ),
            patternType: 'AWS_ACCESS_KEY',
            hunkHeader: l.hunkHeader,
          ),
        );
        continue;
      }

      final jwt = _jwtPattern.firstMatch(content);
      if (jwt != null) {
        out.add(
          _SecretHit(
            filePath: l.filePath,
            lineNumber: l.lineNumber,
            snippet: _Snippet.makeAroundMatch(
              content,
              start: jwt.start,
              end: jwt.end,
              maxLen: HighEntropySecretRule._snippetMaxLen,
            ),
            patternType: 'JWT_TOKEN',
            hunkHeader: l.hunkHeader,
          ),
        );
        continue;
      }

      // Assignment context (key: value / key=value)
      final assign = _assignmentContextPattern.firstMatch(content);
      if (assign != null && assign.groupCount >= 1) {
        final value = assign.group(1);
        if (value != null &&
            value.length >= _minTokenLen &&
            heuristics.isLikelySecret(value, content)) {
          out.add(
            _SecretHit(
              filePath: l.filePath,
              lineNumber: l.lineNumber,
              snippet: _Snippet.makeAroundMatch(
                content,
                start: assign.start,
                end: assign.end,
                maxLen: HighEntropySecretRule._snippetMaxLen,
              ),
              patternType: 'HIGH_ENTROPY_ASSIGNMENT',
              hunkHeader: l.hunkHeader,
            ),
          );
          continue;
        }
      }

      // Token-like in string literal
      final tok = _tokenInStringPattern.firstMatch(content);
      if (tok != null && tok.groupCount >= 1) {
        final value = tok.group(1);
        if (value != null &&
            value.length >= _minTokenLen &&
            heuristics.isLikelySecret(value, content)) {
          out.add(
            _SecretHit(
              filePath: l.filePath,
              lineNumber: l.lineNumber,
              snippet: _Snippet.makeAroundMatch(
                content,
                start: tok.start,
                end: tok.end,
                maxLen: HighEntropySecretRule._snippetMaxLen,
              ),
              patternType: 'TOKEN_IN_STRING',
              hunkHeader: l.hunkHeader,
            ),
          );
          continue;
        }
      }

      // Base64-like (extra guards to reduce false positives)
      final b64 = _base64Pattern.firstMatch(content);
      if (b64 != null) {
        final matched = b64.group(0) ?? '';
        if (matched.length < _minBase64Len) continue; // reduce noise
        if (!(matched.contains('=') ||
            matched.contains('/') ||
            matched.contains('+'))) {
          continue; // pure alnum blobs are too noisy
        }
        if (!heuristics.isLikelySecret(matched, content)) continue;

        out.add(
          _SecretHit(
            filePath: l.filePath,
            lineNumber: l.lineNumber,
            snippet: _Snippet.makeAroundMatch(
              content,
              start: b64.start,
              end: b64.end,
              maxLen: HighEntropySecretRule._snippetMaxLen,
            ),
            patternType: 'BASE64_LIKE',
            hunkHeader: l.hunkHeader,
          ),
        );
        continue;
      }
    }

    return out;
  }
}
