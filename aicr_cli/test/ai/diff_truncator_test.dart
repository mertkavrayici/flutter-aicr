import 'package:test/test.dart';

import 'package:aicr_cli/src/ai/ai.dart';

void main() {
  test('truncate: within budget -> unchanged and truncated=false', () {
    const diff = 'diff --git a/a.dart b/a.dart\n@@ -1 +1 @@\n+hi';
    const truncator = DiffTruncator();

    final out = truncator.truncate(diff, 10_000);
    expect(out.text, diff);
    expect(out.truncated, isFalse);
  });

  test('truncate: over budget -> truncated=true and within maxChars', () {
    final diff = [
      'diff --git a/a.dart b/a.dart',
      'index 111..222 100644',
      '--- a/a.dart',
      '+++ b/a.dart',
      '@@ -1,1 +1,200 @@',
      ...List.filled(300, '+line'),
    ].join('\n');

    const truncator = DiffTruncator();
    final out = truncator.truncate(diff, 200);

    expect(out.truncated, isTrue);
    expect(out.text.length, lessThanOrEqualTo(200));
    // Prefer keeping at least the first file header line.
    expect(out.text, contains('diff --git'));
  });
}



