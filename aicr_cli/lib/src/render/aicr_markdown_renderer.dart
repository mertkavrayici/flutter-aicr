import '../ai/ai.dart';
import '../finding/models/aicr_finding.dart';
import '../report/aicr_report.dart';

final class AicrMarkdownRenderer {
  final bool includeLegacyRules;

  AicrMarkdownRenderer({this.includeLegacyRules = false});

  String render(AicrReport report) {
    final b = StringBuffer();

    b.writeln('# AICR Review Report');
    b.writeln();
    b.writeln('- Repo: **${report.meta.repoName}**');
    b.writeln('- Created: `${report.meta.createdAt}`');
    b.writeln('- Run: `${report.meta.runId}`');
    b.writeln('- Diff hash: `${report.meta.diffHash}`');
    b.writeln('- AI enabled: `${report.meta.aiEnabled}`');
    b.writeln('- File count: `${report.meta.fileCount}`');
    b.writeln();

    b.writeln('## Summary');
    b.writeln();
    b.writeln('- Status: **${report.summary.status.name}**');
    b.writeln(
      '- Rule results: pass `${report.summary.ruleResults.pass}`, warn `${report.summary.ruleResults.warn}`, fail `${report.summary.ruleResults.fail}`',
    );
    b.writeln();

    b.writeln('## Findings');
    b.writeln();

    if (report.findings.isEmpty) {
      b.writeln('_No findings._');
      b.writeln();
    } else {
      _writeFindingsByCategory(b, report.findings);
      b.writeln();
    }

    if (includeLegacyRules) {
      _writeLegacyRulesSection(b, report);
    }

    if (report.aiReview != null) {
      b.writeln('## 🤖 AI Review');
      b.writeln();
      b.writeln(_renderAiReview(report.aiReview!));
      b.writeln();
    }

    if (report.files.isNotEmpty) {
      b.writeln('## Changed files');
      b.writeln();
      for (final f in report.files) {
        b.writeln('- `${f.changeType.name}` `${f.path}`');
      }
      b.writeln();
    }

    return b.toString().trimRight();
  }

  void _writeFindingsByCategory(StringBuffer b, List<AicrFinding> findings) {
    final grouped = <AicrCategory, List<AicrFinding>>{};
    for (final f in findings) {
      (grouped[f.category] ??= <AicrFinding>[]).add(f);
    }

    for (final c in AicrCategory.values) {
      final list = grouped[c];
      if (list == null || list.isEmpty) continue;

      list.sort(_findingSort);

      b.writeln('### ${_categoryTitle(c)}');
      b.writeln();

      for (final f in list) {
        b.writeln('- ${_severityEmoji(f.severity)} **${f.title}**');
        if (f.filePath != null) {
          b.writeln('  - Location: `${f.filePath}`');
        }
        if (f.confidence != null) {
          b.writeln(
            '  - Confidence: `${(f.confidence! * 100).toStringAsFixed(0)}%`',
          );
        }
        b.writeln('  - TR: ${f.messageTr}');
        b.writeln('  - EN: ${f.messageEn}');
      }

      b.writeln();
    }
  }

  int _findingSort(AicrFinding a, AicrFinding b) {
    final s = _severityRank(b.severity).compareTo(_severityRank(a.severity));
    if (s != 0) return s;
    return a.title.compareTo(b.title);
  }

  int _severityRank(AicrSeverity s) => switch (s) {
    AicrSeverity.info => 0,
    AicrSeverity.suggestion => 1,
    AicrSeverity.warning => 2,
    AicrSeverity.critical => 3,
  };

  String _severityEmoji(AicrSeverity s) => switch (s) {
    AicrSeverity.info => 'ℹ️',
    AicrSeverity.suggestion => '💡',
    AicrSeverity.warning => '⚠️',
    AicrSeverity.critical => '🛑',
  };

  String _categoryTitle(AicrCategory c) => switch (c) {
    AicrCategory.architecture => 'Architecture',
    AicrCategory.quality => 'Quality',
    AicrCategory.bugRisk => 'Bug Risk',
    AicrCategory.performance => 'Performance',
    AicrCategory.security => 'Security',
    AicrCategory.testing => 'Testing',
    AicrCategory.dx => 'Developer Experience',
    AicrCategory.nitpick => 'Nitpick',
  };

  void _writeLegacyRulesSection(StringBuffer b, AicrReport report) {
    b.writeln('## Legacy rule results (debug)');
    b.writeln();

    for (final r in report.rules) {
      b.writeln('- **${r.title}** (`${r.ruleId}`) → `${r.status.name}`');
    }

    b.writeln();
  }

  String _renderAiReview(AiReview aiReview) {
    final b = StringBuffer();

    // Summary
    if (aiReview.summary.trim().isNotEmpty) {
      b.writeln('- Summary: ${aiReview.summary}');
    }

    // Highlights
    if (aiReview.highlights.isNotEmpty) {
      b.writeln();
      b.writeln('### Highlights');
      b.writeln();
      for (final highlight in aiReview.highlights) {
        final severityEmoji = _aiSeverityEmoji(highlight.severity);
        b.writeln('$severityEmoji **${highlight.title}**');
        b.writeln('  ${highlight.detail}');
        if (highlight.ruleId != null) {
          b.writeln('  - Rule: `${highlight.ruleId}`');
        }
        b.writeln();
      }
    }

    // Suggested Actions
    if (aiReview.suggestedActions.isNotEmpty) {
      b.writeln('### Suggested Actions');
      b.writeln();
      for (final action in aiReview.suggestedActions) {
        b.writeln('- **${action.priority.name}**: ${action.action}');
      }
      b.writeln();
    }

    // Limitations
    if (aiReview.limitations.isNotEmpty) {
      b.writeln('### Limitations');
      b.writeln();
      for (final limitation in aiReview.limitations) {
        b.writeln('- $limitation');
      }
      b.writeln();
    }

    return b.toString().trimRight();
  }

  String _aiSeverityEmoji(AiSeverity severity) => switch (severity) {
    AiSeverity.info => 'ℹ️',
    AiSeverity.warn => '⚠️',
    AiSeverity.error => '🛑',
  };
}
