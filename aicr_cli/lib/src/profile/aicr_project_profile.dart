/// Repo-aware project profile used to give AI reviewers concise context.
///
/// All fields are optional; missing profile must be treated as an empty profile.
final class AicrProjectProfile {
  final String? projectName;
  final String? architecture;
  final String? stateManagement;
  final String? routing;
  final String? models;
  final String? testing;
  final List<String> forbiddenImports;

  /// Preferred language for AI output: "en" or "tr" (optional).
  final String? language;

  const AicrProjectProfile({
    this.projectName,
    this.architecture,
    this.stateManagement,
    this.routing,
    this.models,
    this.testing,
    this.forbiddenImports = const <String>[],
    this.language,
  });

  static const empty = AicrProjectProfile();

  bool get isEmpty {
    return (projectName == null || projectName!.trim().isEmpty) &&
        (architecture == null || architecture!.trim().isEmpty) &&
        (stateManagement == null || stateManagement!.trim().isEmpty) &&
        (routing == null || routing!.trim().isEmpty) &&
        (models == null || models!.trim().isEmpty) &&
        (testing == null || testing!.trim().isEmpty) &&
        forbiddenImports.isEmpty &&
        (language == null || language!.trim().isEmpty);
  }
}



