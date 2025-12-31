import 'dart:convert';

import 'package:aicr_cli/src/render/aicr_markdown_renderer.dart';

import 'aicr_report.dart';

// Extension to add convenience methods to AicrReport
extension AicrReportExtensions on AicrReport {
  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String toMarkdown({bool includeLegacyRules = false}) =>
      AicrMarkdownRenderer(includeLegacyRules: includeLegacyRules).render(this);
}

