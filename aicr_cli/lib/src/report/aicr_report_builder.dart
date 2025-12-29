import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../finding/models/aicr_finding.dart';
import 'aicr_report.dart';

final class AicrReportBuilder {
  final String repoName;
  final String diffText;
  final List<FileEntry> files;
  final bool aiEnabled;
  final List<RuleResult> ruleResults;
  final List<AicrFinding> aiFindings;

  AicrReportBuilder({
    List<AicrFinding>? aiFindings,
    required this.repoName,
    required this.diffText,
    required this.files,
    required this.aiEnabled,
    required this.ruleResults,
  }) : aiFindings = aiFindings ?? const [];

  AicrReport build() {
    final createdAt = DateTime.now().toIso8601String();
    final runId = 'aicr_${DateTime.now().millisecondsSinceEpoch}';
    final diffHash =
        'sha256:${sha256.convert(utf8.encode(diffText)).toString()}';

    final meta = Meta.fromFlat(
      toolVersion: '0.1.0',
      runId: runId,
      createdAt: createdAt,
      repoName: repoName,
      aiEnabled: aiEnabled,
      diffHash: diffHash,
      fileCount: files.length,
    );

    final passCount = ruleResults
        .where((r) => r.status == ReportStatus.pass)
        .length;
    final warnCount = ruleResults
        .where((r) => r.status == ReportStatus.warn)
        .length;
    final failCount = ruleResults
        .where((r) => r.status == ReportStatus.fail)
        .length;

    final status = failCount > 0
        ? ReportStatus.fail
        : (warnCount > 0 ? ReportStatus.warn : ReportStatus.pass);

    final summary = Summary(
      status: status,
      ruleResults: Counts(pass: passCount, warn: warnCount, fail: failCount),
      contractResults: Counts(pass: 0, warn: 0, fail: 0),
      fileFindings: FileCounts(info: 0, warn: 0, error: 0),
    );

    final deterministic = _buildFindings(ruleResults);
    final findings = _mergeFindings(
      deterministic: deterministic,
      ai: aiEnabled ? aiFindings : const <AicrFinding>[],
    );

    return AicrReport(
      meta: meta,
      summary: summary,
      rules: ruleResults,
      findings: findings,
      contracts: const [],
      files: files,
      recommendations: const [],
      aiReview: null,
    );
  }

  List<AicrFinding> _mergeFindings({
    required List<AicrFinding> deterministic,
    required List<AicrFinding> ai,
  }) {
    // deterministic önce: ana “gerçeklik” bu; AI tamamlayıcı.
    final merged = <AicrFinding>[...deterministic, ...ai];

    return _dedupeById(merged);
  }

  List<AicrFinding> _dedupeById(List<AicrFinding> items) {
    final seen = <String>{};
    final out = <AicrFinding>[];

    for (final f in items) {
      if (seen.add(f.id)) {
        out.add(f);
      }
    }

    return out;
  }

  List<AicrFinding> _buildFindings(List<RuleResult> results) {
    final out = <AicrFinding>[];

    for (final r in results) {
      final severity = _mapSeverity(r);
      if (severity == null) continue;

      final category = _mapCategory(r.ruleId);

      final evidenceFiles = r.evidence
          .map((e) => e['file_path']?.toString())
          .whereType<String>()
          .where((s) => s.trim().isNotEmpty)
          .toList(growable: false);

      final id = _makeFindingId(
        ruleId: r.ruleId,
        title: r.title,
        evidenceFiles: evidenceFiles,
      );

      final primaryPath = _pickPrimaryFilePath(r.ruleId, evidenceFiles);

      out.add(
        AicrFinding(
          filePath: primaryPath,
          id: id,
          category: category,
          severity: severity,
          title: r.title,
          messageTr: r.message['tr'] ?? '',
          messageEn: r.message['en'] ?? '',
          sourceId: r.ruleId,
          confidence: null,
        ),
      );
    }

    return out;
  }

  String? _pickPrimaryFilePath(String ruleId, List<String> evidenceFiles) {
    if (evidenceFiles.isEmpty) return null;

    if (ruleId == 'ui_change_suggests_golden_tests') {
      final preferred = evidenceFiles.firstWhere((p) {
        final n = p.replaceAll('\\', '/').toLowerCase();
        return n.contains('/presentation/') ||
            n.contains('/components/') ||
            n.contains('/widgets/');
      }, orElse: () => evidenceFiles.first);
      return preferred;
    }

    return evidenceFiles.first;
  }

  AicrSeverity? _mapSeverity(RuleResult r) {
    if (r.status == ReportStatus.pass) return null;

    if (r.ruleId == 'large_change_set') return AicrSeverity.suggestion;
    if (r.ruleId == 'ui_change_suggests_golden_tests') {
      return AicrSeverity.suggestion;
    }

    return switch (r.status) {
      ReportStatus.warn => AicrSeverity.warning,
      ReportStatus.fail => AicrSeverity.critical,
      ReportStatus.pass => null,
    };
  }

  AicrCategory _mapCategory(String ruleId) {
    return switch (ruleId) {
      'bloc_change_requires_tests' => AicrCategory.testing,
      'large_change_set' => AicrCategory.dx,
      'ui_change_suggests_golden_tests' => AicrCategory.quality,
      'secret_or_env_exposure' => AicrCategory.security,
      'layer_violation' => AicrCategory.architecture,
      'large_diff_suggests_split' => AicrCategory.performance,
      _ => AicrCategory.quality,
    };
  }

  String _makeFindingId({
    required String ruleId,
    required String title,
    required List<String> evidenceFiles,
  }) {
    final seed = '$ruleId|$title|${evidenceFiles.join(',')}';
    final digest = sha256
        .convert(utf8.encode(seed))
        .toString()
        .substring(0, 12);
    return '$ruleId:$digest';
  }
}
