import '../report/aicr_report.dart';
import 'ai.dart';

final class DeterministicAiReviewService implements AiReviewService {
  @override
  Future<AiReview> generate({
    required String diffText,
    required AicrReport report,
    required AiLanguage language,
  }) async {
    final lang = language;
    final isEmpty = diffText.trim().isEmpty || report.meta.fileCount == 0;

    if (isEmpty) {
      return AiReview(
        status: AiReviewStatus.generated,
        language: lang,
        summary: lang == AiLanguage.tr
            ? 'Diff içeriği boş görünüyor; analiz yalnızca metadata/kurallar üzerinden çalıştı.'
            : 'Diff is empty; analysis ran on metadata/rules only.',
        highlights: const [
          AiReviewHighlight(
            severity: AiSeverity.info,
            title: 'Empty diff',
            detail:
                'No file changes were provided, so findings are naturally empty.',
          ),
        ],
        suggestedActions: [
          AiSuggestedAction(
            priority: AiActionPriority.p1,
            action: lang == AiLanguage.tr
                ? 'Gerçek bir git diff dosyası vererek tekrar çalıştır.'
                : 'Run again with a real git diff file.',
          ),
        ],
        limitations: const ['MVP deterministic mode (no LLM).'],
      );
    }

    final highlights = <AiReviewHighlight>[];
    for (final r in report.rules) {
      if (r.status == ReportStatus.fail) {
        highlights.add(
          AiReviewHighlight(
            severity: AiSeverity.error,
            title: r.title,
            detail: _msg(r, lang),
            ruleId: r.ruleId,
          ),
        );
      } else if (r.status == ReportStatus.warn) {
        highlights.add(
          AiReviewHighlight(
            severity: AiSeverity.warn,
            title: r.title,
            detail: _msg(r, lang),
            ruleId: r.ruleId,
          ),
        );
      }
    }

    final summary = switch (report.summary.status) {
      ReportStatus.pass =>
        lang == AiLanguage.tr
            ? 'Değişiklikler düşük riskli görünüyor. Kurallar ihlal tespit etmedi.'
            : 'Changes look low-risk. No rule violations detected.',
      ReportStatus.warn =>
        lang == AiLanguage.tr
            ? 'Bazı dikkat edilmesi gereken noktalar var. Uyarıları gözden geçir.'
            : 'There are some warnings to review.',
      ReportStatus.fail =>
        lang == AiLanguage.tr
            ? 'Değişiklikler yüksek risk taşıyor. Fail veren kuralları düzeltmeden merge etme.'
            : 'Changes are high-risk. Do not merge before addressing failed rules.',
    };

    if (highlights.isEmpty) {
      highlights.add(
        AiReviewHighlight(
          severity: AiSeverity.info,
          title: lang == AiLanguage.tr
              ? 'Önemli bulgu yok'
              : 'No notable findings',
          detail: lang == AiLanguage.tr
              ? 'Kurallar bulgu üretmedi. Kritik değişikliklerde CI/test doğrulaması önerilir.'
              : 'Rules produced no findings. Validate with CI/tests for critical changes.',
        ),
      );
    }

    return AiReview(
      status: AiReviewStatus.generated,
      language: lang,
      summary: summary,
      highlights: highlights,
      suggestedActions: [
        AiSuggestedAction(
          priority: report.summary.status == ReportStatus.fail
              ? AiActionPriority.p0
              : AiActionPriority.p1,
          action: lang == AiLanguage.tr
              ? 'Rule çıktılarındaki kanıtları (evidence) takip ederek düzeltmeleri uygula.'
              : 'Apply fixes by following rule evidence in the report.',
        ),
      ],
      limitations: const ['MVP deterministic mode (no LLM).'],
    );
  }

  String _msg(RuleResult r, AiLanguage language) {
    if (language == AiLanguage.tr)
      return r.message['tr'] ?? r.message.values.first;
    return r.message['en'] ?? r.message.values.first;
  }
}
