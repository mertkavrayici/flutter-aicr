final class AiReviewInput {
  final String repoName;
  final String diffText;
  final List<String> changedFiles;
  final Map<String, String> metadata;

  AiReviewInput({
    required this.repoName,
    required this.diffText,
    required this.changedFiles,
    Map<String, String>? metadata,
  }) : metadata = metadata ?? const {};
}
