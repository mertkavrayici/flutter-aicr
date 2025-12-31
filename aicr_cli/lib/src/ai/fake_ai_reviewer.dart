import 'dart:convert';
import 'dart:math';
import 'package:aicr_cli/src/finding/models/aicr_finding.dart';
import 'package:crypto/crypto.dart';

import 'ai_review_request.dart';
import 'ai_review_result.dart';
import 'ai_reviewer.dart';

/// Demo / smoke tester:
/// - Demo/test amaçlı; prod default Noop olmalı.
/// - Opsiyonel fixture findings verilebilir (testlerde determinism için).
/// - Fixture yoksa diff + changed files üzerinden basit heuristics ile 1-3 adet
///   actionable finding üretir.
final class FakeAiReviewer implements AiReviewer {
  final List<AicrFinding>? fixtureFindings;

  const FakeAiReviewer({this.fixtureFindings});

  @override
  Future<AiReviewResult> review(AiReviewRequest request) async {
    try {
      final fixtures = fixtureFindings;
      if (fixtures != null) {
        return AiReviewResult.ok(
          findings: fixtures.take(max(0, request.maxFindings)).toList(),
          model: 'fake',
          truncated: false,
        );
      }

      final originalDiffText = request.diffText;
      final truncated = originalDiffText.length > request.maxInputChars;
      final diffText = truncated
          ? originalDiffText.substring(0, request.maxInputChars)
          : originalDiffText;

      final changedLower = _extractChangedFilesFromDiff(diffText)
          .map((e) => e.replaceAll('\\', '/').toLowerCase().trim())
          .where((p) => p.isNotEmpty)
          .toList(growable: false);

      final primaryPath =
          _pickPrimary(changedLower) ?? _extractFirstFilePathFromDiff(diffText);
      final diffUpper = diffText.toUpperCase();

      final out = <AicrFinding>[];

      void add(AicrFinding finding) {
        if (out.length >= request.maxFindings) return;
        out.add(finding);
      }

      // 1) Security: .env / secret-ish patterns
      if (_hasSecretSmell(diffUpper)) {
        add(
          _aiFinding(
            seed: 'secret-smell|${request.repoName}|$primaryPath|${request.diffHash}',
            category: AicrCategory.security,
            severity: AicrSeverity.warning,
            title: 'Possible secret exposure',
            tr: 'Diff içinde `.env`/secret/apiKey/token benzeri pattern’ler var. Hardcode edilmiş credential olmadığını ve loglara sızmadığını doğrula.',
            en: 'Diff contains `.env`/secret/apiKey/token-like patterns. Verify nothing is hardcoded and nothing leaks to logs.',
            filePath: primaryPath,
            confidence: 0.72,
          ),
        );
      }

      // 2) Testing: BLoC changed but no tests touched (best-effort heuristic)
      final blocChanged = _looksLikeBlocChange(changedLower) ||
          diffUpper.contains('BLOC') ||
          diffUpper.contains('CUBIT');
      final testsTouched = _looksLikeTestsTouched(changedLower);
      if (blocChanged && !testsTouched) {
        final blocFile = changedLower.firstWhere(
          (p) => _isBlocishPath(p),
          orElse: () => changedLower.isEmpty ? '' : changedLower.first,
        );
        add(
          _aiFinding(
            seed: 'bloc-no-tests|${request.repoName}|$blocFile|${request.diffHash}',
            category: AicrCategory.testing,
            severity: AicrSeverity.warning,
            title: 'BLoC changes should include tests',
            tr: 'BLoC/Cubit değişikliği var ama test dosyası değişmemiş görünüyor. İlgili unit/widget test eklemeyi düşün.',
            en: 'BLoC/Cubit changes detected but no test file seems changed. Consider adding/updating unit/widget tests.',
            filePath: blocFile.isEmpty ? null : blocFile,
            confidence: 0.66,
          ),
        );
      }

      // 3) Large diff => review recommended
      if (_isLargeDiff(diffText)) {
        add(
          _aiFinding(
            seed: 'large-diff|${request.repoName}|${request.diffHash}',
            category: AicrCategory.dx,
            severity: AicrSeverity.warning,
            title: 'Large diff—review recommended',
            tr: 'Diff oldukça büyük görünüyor. Değişikliği parçalara bölmek veya ekstra dikkatli review yapmak iyi olur.',
            en: 'Diff looks large. Consider splitting the change or doing a more thorough review.',
            filePath: null,
            confidence: 0.55,
          ),
        );
      }

      return AiReviewResult.ok(
        findings: out,
        model: 'fake',
        truncated: truncated,
      );
    } catch (e) {
      // No-throw policy: best-effort error container.
      return AiReviewResult.error(errorMessage: e.toString(), model: 'fake');
    }
  }

  bool _isLargeDiff(String diffText) {
    // Keep thresholds intentionally simple and stable.
    final lineCount = '\n'.allMatches(diffText).length + 1;
    if (lineCount >= 600) return true;
    if (diffText.length >= 50_000) return true;
    return false;
  }

  List<String> _extractChangedFilesFromDiff(String diffText) {
    final out = <String>{};
    for (final raw in diffText.split('\n')) {
      final line = raw.trimRight();
      if (!line.startsWith('+++ ') && !line.startsWith('--- ')) continue;
      final p = line.substring(4).trim();
      if (p.isEmpty || p == '/dev/null') continue;
      if (p.startsWith('a/')) out.add(p.substring(2));
      if (p.startsWith('b/')) out.add(p.substring(2));
    }
    return out.toList(growable: false);
  }

  bool _looksLikeTestsTouched(List<String> changedLower) {
    return changedLower.any(
      (p) => p.contains('/test/') || p.endsWith('_test.dart'),
    );
  }

  bool _looksLikeBlocChange(List<String> changedLower) {
    return changedLower.any(_isBlocishPath);
  }

  bool _isBlocishPath(String p) {
    if (!p.endsWith('.dart')) return false;
    // Heuristic: common Flutter+BLoC naming.
    return p.contains('/bloc/') ||
        p.contains('/cubit/') ||
        p.contains('bloc') ||
        p.contains('cubit');
  }

  bool _hasSecretSmell(String diffUpper) {
    // Shallow heuristics: intended to be noisy but cheap.
    final patterns = <String>[
      '.ENV',
      'SECRET',
      'APIKEY',
      'API_KEY',
      'TOKEN=',
      'TOKEN:',
    ];
    return patterns.any(diffUpper.contains);
  }

  AicrFinding _aiFinding({
    required Object seed,
    required AicrCategory category,
    required AicrSeverity severity,
    required String title,
    required String tr,
    required String en,
    String? filePath,
    double? confidence,
  }) {
    final digest = sha256.convert(utf8.encode(seed.toString())).toString();
    final id = 'ai:${digest.substring(0, 12)}';

    return AicrFinding(
      id: id,
      category: category,
      severity: severity,
      title: title,
      messageTr: tr,
      messageEn: en,
      filePath: filePath,
      sourceId: 'ai_fake',
      source: AicrFindingSource.ai,
      confidence: confidence,
    );
  }

  String? _pickPrimary(List<String> changedFiles) {
    if (changedFiles.isEmpty) return null;

    // UI dosyaları varsa onları öne al
    final preferred = changedFiles.firstWhere(
      (p) =>
          p.contains('/presentation/') ||
          p.contains('/widgets/') ||
          p.contains('/components/'),
      orElse: () => changedFiles.first,
    );
    return preferred;
  }

  String? _extractFirstFilePathFromDiff(String diffText) {
    // Try to capture the first "+++ b/<path>" line.
    for (final raw in diffText.split('\n')) {
      final line = raw.trimRight();
      if (!line.startsWith('+++ ')) continue;
      final p = line.substring(4).trim();
      if (p == '/dev/null') continue;
      if (p.startsWith('b/')) return p.substring(2);
      return p;
    }
    return null;
  }
}
