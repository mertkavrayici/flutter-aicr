import '../../aicr_cli.dart';
import 'markdown_builder.dart';
import 'shared_markdown_blocks.dart';

part 'pr_comment_renderer/meta_section.dart';
part 'pr_comment_renderer/signals_table_section.dart';
part 'pr_comment_renderer/review_decision_section.dart';
part 'pr_comment_renderer/top_actions_section.dart';
part 'pr_comment_renderer/findings_section.dart';

part 'pr_comment_renderer/risk_level_calculator.dart';
part 'pr_comment_renderer/overall_confidence_helper.dart';
part 'pr_comment_renderer/review_decision_builder.dart';
part 'pr_comment_renderer/top_actions_selector.dart';

final class PrCommentRenderer {
  String render(AicrReport report, {String locale = 'en'}) {
    final md = MarkdownBuilder();

    final status = report.summary.status.name.toUpperCase();
    md.h2('AICR — $status');

    final riskLevel = _risk().calculate(report);
    final overallConfidence = _confidence().calculate(report);

    MetaSection().render(
      md,
      report,
      riskLevel: riskLevel,
      overallConfidence: overallConfidence,
      overallConfidenceText: _confidence().format(overallConfidence),
    );
    SignalsTableSection().render(md, report, aiCount: _aiCount(report));
    ReviewDecisionSection().render(
      md,
      report,
      overallConfidence: overallConfidence,
      decisionText: _decision().build(
        report,
        overallConfidence: overallConfidence,
      ),
    );
    TopActionsSection().render(
      md,
      report,
      locale: locale,
      top: _topActions().select(report, limit: 5),
      isAi: _isAi,
      confTag: _conf,
      msg: _msg,
    );
    FindingsSection().render(
      md,
      report,
      locale: locale,
      sevRank: _sevRank,
      isAi: _isAi,
      confTag: _conf,
      msg: _msg,
    );

    return md.toString();
  }

  int _aiCount(AicrReport report) => report.findings.where(_isAi).length;

  bool _isAi(AicrFinding f) => (f.sourceId ?? '').startsWith('ai');

  String _conf(AicrFinding f) =>
      f.confidence == null ? '' : ', ${(f.confidence! * 100).round()}%';

  String _msg(AicrFinding f, String locale) =>
      locale == 'tr' ? f.messageTr : f.messageEn;

  int _sevRank(AicrSeverity s) => switch (s) {
    AicrSeverity.critical => 4,
    AicrSeverity.warning => 3,
    AicrSeverity.suggestion => 2,
    AicrSeverity.info => 1,
  };

  _RiskLevelCalculator _risk() =>
      _RiskLevelCalculator(sevRank: _sevRank);

  _OverallConfidenceHelper _confidence() => _OverallConfidenceHelper(
        isAi: _isAi,
        sevRank: _sevRank,
      );

  _ReviewDecisionBuilder _decision() => _ReviewDecisionBuilder(
        aiCount: _aiCount,
        confidence: _confidence(),
      );

  _TopActionsSelector _topActions() => _TopActionsSelector(
        isAi: _isAi,
        sevRank: _sevRank,
      );
}
