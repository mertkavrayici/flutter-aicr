import 'dart:io';

import 'package:aicr_cli/aicr_cli.dart';
import 'package:aicr_cli/src/render/pr_comment_renderer.dart';
import 'package:aicr_cli/src/ai/ai.dart';

Future<void> main() async {
  // fixture diff dosyan varsa onu oku:
  // örn: test/fixtures/sample.diff
  final diffText = File('test/fixtures/sample.diff').readAsStringSync();

  final report = await AicrEngine.analyze(
    diffText: diffText,
    files: [
      FileEntry.fromStringChangeType(
        path: 'test/fixtures/sample.diff',
        changeType: 'modified',
      ),
    ],
    aiEnabled: true,
    repoName: 'flutter-aicr',
    language: AiLanguage.en,
    aiReviewer: const FakeAiReviewer(), // ai finding gör diye (legacy)
  );

  final md = PrCommentRenderer().render(report, locale: 'en');

  // terminale bas
  stdout.writeln(md);
}
