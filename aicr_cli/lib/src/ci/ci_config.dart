/// CI configuration loaded from `.aicr/ci.yaml`.
final class CiConfig {
  final bool postComment;
  final String commentMode;
  final String marker;

  const CiConfig({
    this.postComment = false,
    this.commentMode = 'update',
    this.marker = 'AICR_COMMENT',
  });

  static const CiConfig empty = CiConfig();

  bool get isEmpty => this == empty;
}

