/// Supported AI modes.
///
/// Keep this enum small and CLI-stable (string values are `.name`).
enum AiMode { noop, fake, openai }

extension AiModeParsing on AiMode {
  static AiMode fromString(String? raw) => switch ((raw ?? '').trim()) {
    'fake' => AiMode.fake,
    'openai' => AiMode.openai,
    _ => AiMode.noop,
  };
}


