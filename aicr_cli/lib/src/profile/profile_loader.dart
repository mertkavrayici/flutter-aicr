import 'dart:io';

import 'aicr_project_profile.dart';

/// Loads `AicrProjectProfile` from YAML, with repo-root priority and in-memory cache.
///
/// Priority:
///  a) <repoRoot>/.aicr/profile.yaml
///  b) <repoRoot>/aicr_profile.yaml
///
/// No-throw: missing/invalid files return an empty profile.
final class ProfileLoader {
  final Map<String, _CacheEntry> _cache = <String, _CacheEntry>{};

  bool lastProfileLoaded = false;
  String? lastProfilePath;

  AicrProjectProfile load(String repoPath) {
    final key = _normalizeRepoPath(repoPath);
    final cached = _cache[key];
    if (cached != null) {
      lastProfileLoaded = cached.loaded;
      lastProfilePath = cached.path;
      return cached.profile;
    }

    final candidates = <String>[
      '$key/.aicr/profile.yaml',
      '$key/aicr_profile.yaml',
    ];

    for (final p in candidates) {
      try {
        final file = File(p);
        if (!file.existsSync()) continue;
        final yaml = file.readAsStringSync();
        final profile = _parseYamlSubset(yaml);
        final entry = _CacheEntry(profile: profile, loaded: !profile.isEmpty, path: p);
        _cache[key] = entry;
        lastProfileLoaded = entry.loaded;
        lastProfilePath = entry.path;
        return entry.profile;
      } catch (_) {
        // keep searching; no-throw
      }
    }

    final entry = const _CacheEntry(profile: AicrProjectProfile.empty, loaded: false, path: null);
    _cache[key] = entry;
    lastProfileLoaded = false;
    lastProfilePath = null;
    return AicrProjectProfile.empty;
  }

  static String _normalizeRepoPath(String p) {
    final n = p.trim();
    if (n.isEmpty) return Directory.current.path;
    return n.endsWith(Platform.pathSeparator)
        ? n.substring(0, n.length - 1)
        : n;
  }

  /// Minimal YAML subset parser for this profile format.
  ///
  /// Supported:
  /// - `key: value` (string)
  /// - `key:` + list items on following lines `- item`
  /// - block scalar `key: |` with indented lines (joined by '\n')
  AicrProjectProfile _parseYamlSubset(String yaml) {
    try {
      final lines = yaml.split('\n');

      final map = <String, Object?>{};
      String? currentKey;
      bool currentIsBlock = false;
      final currentBlock = <String>[];
      final currentList = <String>[];
      int? currentIndent;

      void flush() {
        if (currentKey == null) return;
        if (currentIsBlock) {
          map[currentKey!] = currentBlock.join('\n').trimRight();
        } else if (currentList.isNotEmpty) {
          map[currentKey!] = currentList.toList(growable: false);
        }
        currentKey = null;
        currentIsBlock = false;
        currentBlock.clear();
        currentList.clear();
        currentIndent = null;
      }

      for (final raw in lines) {
        final line = raw.replaceAll('\r', '');
        final trimmed = line.trim();
        if (trimmed.isEmpty) {
          // treat as part of block scalar if applicable
          if (currentIsBlock && currentKey != null) currentBlock.add('');
          continue;
        }
        if (trimmed.startsWith('#')) continue;

        final keyMatch = RegExp(r'^([A-Za-z0-9_]+)\s*:\s*(.*)$').firstMatch(trimmed);
        if (keyMatch != null) {
          flush();
          currentKey = keyMatch.group(1);
          final value = keyMatch.group(2) ?? '';

          if (value == '|' || value == '>') {
            currentIsBlock = true;
            currentIndent = _leadingSpaces(line);
            continue;
          }

          if (value.isEmpty) {
            currentIsBlock = false;
            currentIndent = _leadingSpaces(line);
            continue;
          }

          map[currentKey!] = _stripQuotes(value);
          currentKey = null;
          continue;
        }

        // list item or block line under a key
        if (currentKey != null) {
          final indent = _leadingSpaces(line);
          if (currentIndent != null && indent <= currentIndent!) {
            // end of nested section
            flush();
            // re-process this line as top-level by skipping (MVP).
            continue;
          }

          if (currentIsBlock) {
            currentBlock.add(line.substring(currentIndent ?? 0).trimRight());
            continue;
          }

          final li = RegExp(r'^\s*-\s*(.*)$').firstMatch(line);
          if (li != null) {
            currentList.add(_stripQuotes(li.group(1) ?? ''));
          }
        }
      }

      flush();

      final forbidden = (map['forbiddenImports'] is List)
          ? (map['forbiddenImports'] as List)
                .whereType<String>()
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList(growable: false)
          : const <String>[];

      final lang = (map['language'] as String?)?.trim();
      final normalizedLang = (lang == null || lang.isEmpty) ? null : lang;

      return AicrProjectProfile(
        projectName: map['projectName'] as String?,
        architecture: map['architecture'] as String?,
        stateManagement: map['stateManagement'] as String?,
        routing: map['routing'] as String?,
        models: map['models'] as String?,
        testing: map['testing'] as String?,
        forbiddenImports: forbidden,
        language: normalizedLang,
      );
    } catch (_) {
      return AicrProjectProfile.empty;
    }
  }

  static int _leadingSpaces(String s) {
    var i = 0;
    while (i < s.length && s.codeUnitAt(i) == 32) {
      i++;
    }
    return i;
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
  final AicrProjectProfile profile;
  final bool loaded;
  final String? path;

  const _CacheEntry({required this.profile, required this.loaded, required this.path});
}



