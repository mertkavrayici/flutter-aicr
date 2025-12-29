import 'dart:convert';
import 'package:aicr_cli/src/finding/models/aicr_finding.dart';
import 'package:crypto/crypto.dart';

import 'ai_review_input.dart';
import 'ai_reviewer.dart';

/// Demo / smoke tester:
/// - Diff'e ve file listesine bakıp 1-2 adet "AI yorum" finding'i üretir.
/// - Gerçek LLM entegrasyonu gelene kadar ürün hissini test etmek için yeterli.
final class FakeAiReviewer implements AiReviewer {
  const FakeAiReviewer();

  @override
  Future<List<AicrFinding>> review(AiReviewInput input) async {
    final changed = input.changedFiles.map((e) => e.toLowerCase()).toList();

    final out = <AicrFinding>[];

    // 1) Dokümantasyon önerisi (DX)
    final touchedDocs = changed.any(
      (p) =>
          p.endsWith('readme.md') ||
          p.endsWith('changelog.md') ||
          p.contains('/docs/'),
    );

    if (!touchedDocs) {
      out.add(
        _aiFinding(
          seed:
              'docs|${input.repoName}|${changed.join(",")}', // id deterministic
          category: AicrCategory.dx,
          severity: AicrSeverity.suggestion,
          title: 'Docs/Changelog gözden geçir',
          tr: 'Bu değişiklik seti kullanıcıyı/ekibi etkileyebilir. README veya CHANGELOG güncellemesi gerekip gerekmediğini kontrol et.',
          en: 'This change set may impact users/the team. Consider whether README or CHANGELOG updates are needed.',
          filePath: _pickPrimary(changed),
          confidence: 0.62,
        ),
      );
    }

    // 2) Güvenlik kokusu: diff içinde "API_KEY/SECRET/TOKEN" gibi stringler
    final diffUpper = input.diffText.toUpperCase();
    final smells = <String>[
      'API_KEY',
      'SECRET',
      'TOKEN',
      'PASSWORD',
      'BEARER ',
    ];
    final hit = smells.any(diffUpper.contains);

    if (hit) {
      out.add(
        _aiFinding(
          seed: 'security-smell|${sha256.convert(utf8.encode(input.diffText))}',
          category: AicrCategory.security,
          severity: AicrSeverity.warning,
          title: 'Olası secret/token sızıntısı',
          tr: 'Diff içinde secret/token benzeri ifadeler geçti. Hardcode edilmiş credential olmadığını ve loglara düşmediğini doğrula.',
          en: 'Diff contains secret/token-like terms. Verify nothing is hardcoded and nothing leaks to logs.',
          filePath: _pickPrimary(changed),
          confidence: 0.74,
        ),
      );
    }

    return out;
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
}
