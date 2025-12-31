import 'dart:io';

import 'ci_config.dart';

/// Loads `CiConfig` from `.aicr/ci.yaml`.
///
/// No-throw: missing/invalid files return default config.
final class CiConfigLoader {
  final Map<String, _CacheEntry> _cache = <String, _CacheEntry>{};

  bool lastConfigLoaded = false;
  String? lastConfigPath;

  CiConfig load(String repoPath) {
    final key = _normalizeRepoPath(repoPath);
    final cached = _cache[key];
    if (cached != null) {
      lastConfigLoaded = cached.loaded;
      lastConfigPath = cached.path;
      return cached.config;
    }

    final configPath = '$key/.aicr/ci.yaml';

    try {
      final file = File(configPath);
      if (!file.existsSync()) {
        final entry =
            const _CacheEntry(config: CiConfig.empty, loaded: false, path: null);
        _cache[key] = entry;
        lastConfigLoaded = false;
        lastConfigPath = null;
        return CiConfig.empty;
      }

      final yaml = file.readAsStringSync();
      final config = _parseYaml(yaml);
      final entry =
          _CacheEntry(config: config, loaded: !config.isEmpty, path: configPath);
      _cache[key] = entry;
      lastConfigLoaded = entry.loaded;
      lastConfigPath = entry.path;
      return entry.config;
    } catch (_) {
      final entry =
          const _CacheEntry(config: CiConfig.empty, loaded: false, path: null);
      _cache[key] = entry;
      lastConfigLoaded = false;
      lastConfigPath = null;
      return CiConfig.empty;
    }
  }

  static String _normalizeRepoPath(String p) {
    final n = p.trim();
    if (n.isEmpty) return Directory.current.path;
    return n.endsWith(Platform.pathSeparator)
        ? n.substring(0, n.length - 1)
        : n;
  }

  /// Minimal YAML parser for CI config format.
  ///
  /// Supports:
  /// - `key: value` (string, bool)
  CiConfig _parseYaml(String yaml) {
    try {
      final lines = yaml.split('\n');
      final map = <String, Object?>{};

      for (final raw in lines) {
        final line = raw.replaceAll('\r', '');
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

        final keyMatch = RegExp(r'^([A-Za-z0-9_]+)\s*:\s*(.*)$').firstMatch(trimmed);
        if (keyMatch != null) {
          final key = keyMatch.group(1)!;
          var value = keyMatch.group(2) ?? '';
          // Strip inline comments
          final commentIndex = value.indexOf('#');
          if (commentIndex >= 0) {
            value = value.substring(0, commentIndex);
          }
          final stripped = _stripQuotes(value.trim());

          if (key == 'postComment') {
            // Parse bool: true, false, "true", "false"
            map[key] = stripped.toLowerCase() == 'true';
          } else {
            map[key] = stripped;
          }
        }
      }

      final postComment = (map['postComment'] as bool?) ?? false;
      final commentMode = (map['commentMode'] as String?)?.trim() ?? 'update';
      final marker = (map['marker'] as String?)?.trim() ?? 'AICR_COMMENT';

      // Validate commentMode
      final validCommentMode =
          (commentMode == 'update' || commentMode == 'always_new')
              ? commentMode
              : 'update';

      return CiConfig(
        postComment: postComment,
        commentMode: validCommentMode,
        marker: marker.isNotEmpty ? marker : 'AICR_COMMENT',
      );
    } catch (_) {
      return CiConfig.empty;
    }
  }

  static String _stripQuotes(String s) {
    final t = s.trim();
    if (t.length >= 2) {
      final first = t[0];
      final last = t[t.length - 1];
      if ((first == '"' && last == '"') || (first == "'" && last == "'")) {
        return t.substring(1, t.length - 1);
      }
    }
    return t;
  }
}

final class _CacheEntry {
  final CiConfig config;
  final bool loaded;
  final String? path;

  const _CacheEntry({
    required this.config,
    required this.loaded,
    required this.path,
  });
}

