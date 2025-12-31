# AICR Flow Documentation

This document describes the complete flow of AICR from CLI entry point to final output, including error handling, fallbacks, and AI review behavior.

## Overview

AICR follows a single-entry-point architecture where all analysis flows through `AicrEngine.analyze()`. The system is designed with error tolerance: deterministic rules always run, and AI review failures never break the analysis.

## Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLI Entry Point                         │
│                    bin/aicr_cli.dart (main)                     │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
                    ┌────────────────┐
                    │  Parse Args    │
                    │  - repo        │
                    │  - repo-path   │
                    │  - mode        │
                    │  - range       │
                    │  - diff        │
                    │  - format      │
                    │  - ai          │
                    │  - lang        │
                    └────────┬───────┘
                             │
                ┌────────────┴────────────┐
                │                         │
                ▼                         ▼
    ┌──────────────────────┐  ┌──────────────────────┐
    │  Input: Diff File    │  │  Input: Git Command  │
    │  --diff <path>        │  │  git diff [range]    │
    └──────────┬───────────┘  └──────────┬───────────┘
               │                          │
               └──────────┬───────────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │   Get Diff Text       │
              │   - From file OR      │
              │   - From git command  │
              └───────────┬───────────┘
                          │
                ┌─────────┴─────────┐
                │                   │
                ▼                   ▼
    ┌──────────────────┐  ┌──────────────────────┐
    │  Mode: git_diff  │  │ Mode: git_name_     │
    │  (default)       │  │        status       │
    │                   │  │  + --repo-path      │
    │  diffText only    │  │                     │
    └─────────┬─────────┘  │  diffText +         │
              │            │  FileEntry[]        │
              │            └──────────┬──────────┘
              │                       │
              └───────────┬───────────┘
                          │
                          ▼
        ┌─────────────────────────────────────┐
        │     AicrEngine.analyze()            │
        │     Single Entry Point               │
        └─────────────────┬───────────────────┘
                          │
                          ▼
        ┌─────────────────────────────────────┐
        │   Step 1: Resolve File List         │
        │                                     │
        │   IF files provided:                │
        │     Use provided FileEntry[]        │
        │   ELSE:                              │
        │     Parse diffText → FileEntry[]    │
        │     (fallback: all 'modified')      │
        └─────────────────┬───────────────────┘
                          │
                          ▼
        ┌─────────────────────────────────────┐
        │   Step 2: Extract Changed Files     │
        │                                     │
        │   changedFiles = files.map(path)    │
        └─────────────────┬───────────────────┘
                          │
                          ▼
        ┌─────────────────────────────────────┐
        │   Step 3: Evaluate Rules            │
        │                                     │
        │   Rules (deterministic):             │
        │   - BlocChangeRequiresTestsRule     │
        │   - SecretOrEnvExposureRule         │
        │   - LargeChangeSetRule              │
        │   - UiChangeSuggestsGoldenTestsRule │
        │   - LayerViolationRule              │
        │   - LargeDiffSuggestsSplitRule      │
        │                                     │
        │   ruleResults = rules.map(evaluate) │
        └─────────────────┬───────────────────┘
                          │
                          ▼
        ┌─────────────────────────────────────┐
        │   Step 4: Build Initial Report      │
        │                                     │
        │   AicrReportBuilder:                │
        │   - Meta (tool, repo, input, ai)    │
        │   - Summary (status, counts)        │
        │   - Rules (ruleResults)             │
        │   - Findings (from rules)           │
        │   - Files (FileEntry[])             │
        │                                     │
        │   reportWithoutAi = builder.build()  │
        └─────────────────┬───────────────────┘
                          │
                ┌─────────┴─────────┐
                │                   │
                ▼                   ▼
    ┌──────────────────┐  ┌──────────────────┐
    │   AI OFF         │  │   AI ON          │
    │   (--ai=false)   │  │   (--ai=true)    │
    └─────────┬────────┘  └─────────┬────────┘
              │                     │
              │                     ▼
              │         ┌───────────────────────┐
              │         │ Step 5: AI Review     │
              │         │                       │
              │         │ DeterministicAi      │
              │         │ ReviewService         │
              │         │ .generate()           │
              │         └───────────┬───────────┘
              │                     │
              │         ┌───────────┴───────────┐
              │         │                       │
              │         ▼                       ▼
              │  ┌──────────────┐    ┌──────────────────┐
              │  │   Success    │    │   Failure        │
              │  │               │    │   (catch)        │
              │  │ aiReview =    │    │                  │
              │  │   AiReview    │    │ aiReview = null  │
              │  │               │    │ aiFindings = []  │
              │  │ aiFindings =  │    │                  │
              │  │   mapped     │    │ Continue without │
              │  │   findings   │    │   AI review      │
              │  └──────┬───────┘    └────────┬─────────┘
              │         │                     │
              │         └──────────┬──────────┘
              │                    │
              └──────────┬─────────┘
                         │
                         ▼
        ┌─────────────────────────────────────┐
        │   Step 6: Merge Findings            │
        │                                     │
        │   findings = merge(                  │
        │     deterministic,                   │
        │     ai                              │
        │   )                                 │
        │                                     │
        │   - Deterministic findings first    │
        │   - AI findings appended            │
        │   - Deduplicate by ID               │
        └─────────────────┬───────────────────┘
                          │
                          ▼
        ┌─────────────────────────────────────┐
        │   Step 7: Build Final Report        │
        │                                     │
        │   AicrReport(                       │
        │     meta,                            │
        │     summary,                         │
        │     rules,                           │
        │     findings,                        │
        │     files,                           │
        │     aiReview                         │
        │   )                                 │
        └─────────────────┬───────────────────┘
                          │
                          ▼
        ┌─────────────────────────────────────┐
        │   Step 8: Render Output              │
        │                                     │
        │   IF format == 'json':               │
        │     report.toPrettyJson()            │
        │   ELSE IF format == 'pr_comment':    │
        │     PrCommentRenderer.render()       │
        └─────────────────┬───────────────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │   Write to File       │
              │   + Print to stdout   │
              └───────────────────────┘
```

## Detailed Flow Steps

### 1. CLI Entry Point (`bin/aicr_cli.dart`)

**Responsibilities:**
- Parse command-line arguments
- Validate inputs
- Handle errors with user-friendly messages

**Input Sources:**
- `--diff <path>`: Read diff from file
- `--repo-path` + `--range`: Execute `git diff` command
- `--mode git_name_status` + `--repo-path`: Use `GitChangedFilesService` for accurate file change types

**Error Handling:**
- Missing diff file → Exit with error message
- Git command failure → Exit with error message
- Invalid arguments → Show usage and exit

### 2. Input Processing

#### Option A: Diff File Input
```dart
if (results['diff'] != null) {
  diffText = File(results['diff']).readAsStringSync();
}
```

#### Option B: Git Command Input
```dart
diffText = await _getGitDiffText(
  repoPath: repoPath,
  mode: mode,
  range: results['range'],
);
```

#### Option C: File List (when `--mode git_name_status`)
```dart
if (mode == CliMode.gitNameStatus && results['repo-path'] != null) {
  files = await _getChangedFiles(repoPath: repoPath, range: range);
}
```

### 3. Engine Analysis (`AicrEngine.analyze()`)

**Single Entry Point:** All analysis flows through this method.

#### Step 1: Resolve File List

**Fallback Strategy:**
```dart
final resolvedFiles = (files != null && files.isNotEmpty)
    ? files  // Use provided files (accurate change types)
    : DiffParser.parseChangedFiles(diffText)  // Fallback: parse from diff
        .map((p) => FileEntry.fromStringChangeType(
          path: p,
          changeType: 'modified',  // Default: all 'modified'
        ))
        .toList();
```

**Why:** CLI may provide accurate `FileEntry[]` with correct change types (added/deleted/modified/renamed) via `GitChangedFilesService`. If not provided, fallback to parsing diff text (all files marked as 'modified').

#### Step 2: Extract Changed Files

Simple mapping to file paths for rule evaluation:
```dart
final changedFiles = resolvedFiles.map((e) => e.path).toList();
```

#### Step 3: Evaluate Rules

**Deterministic Rules (Always Run):**
1. `BlocChangeRequiresTestsRule` - Checks for BLoC test files
2. `SecretOrEnvExposureRule` - Detects potential secret exposure
3. `LargeChangeSetRule` - Flags large file changes (threshold: 15)
4. `UiChangeSuggestsGoldenTestsRule` - Suggests golden tests for UI
5. `LayerViolationRule` - Detects architecture violations
6. `LargeDiffSuggestsSplitRule` - Suggests splitting large diffs

**Rule Evaluation:**
```dart
final ruleResults = rules
    .map((r) => r.evaluate(changedFiles: changedFiles, diffText: diffText))
    .toList();
```

Each rule returns a `RuleResult` with:
- `ruleId`: Unique identifier
- `status`: `pass`, `warn`, or `fail`
- `title`: Human-readable title
- `message`: Bilingual message (tr/en)
- `evidence`: Supporting file paths

#### Step 4: Build Initial Report

**AicrReportBuilder** creates the base report:

```dart
final builder = AicrReportBuilder(
  repoName: repoName,
  diffText: diffText,
  files: resolvedFiles,
  aiEnabled: aiEnabled,
  ruleResults: ruleResults,
  aiFindings: const [],  // Will be populated later if AI enabled
);

final reportWithoutAi = builder.build();
```

**Report Components:**
- **Meta**: Tool version, run ID, timestamp, repo info, input hash, AI enabled flag
- **Summary**: Overall status (pass/warn/fail), rule counts, contract counts, file finding counts
- **Rules**: All rule results
- **Findings**: Findings derived from rule results (non-pass rules)
- **Files**: List of changed files

### 5. AI Review (Conditional)

#### AI OFF (`--ai=false`)

**Behavior:**
- Skip AI review entirely
- `aiReview = null`
- `aiFindings = []`
- Report includes only deterministic findings

#### AI ON (`--ai=true`)

**Service:** `DeterministicAiReviewService` (default)

**Flow:**
```dart
if (aiEnabled) {
  final service = aiReviewService ?? DeterministicAiReviewService();
  try {
    aiReview = await service.generate(
      diffText: diffText,
      report: reportWithoutAi,
      language: language,
    );
    aiFindings = AiReviewMapper.toFindings(aiReview);
  } catch (_) {
    // AI review generation failed, continue without it
    aiReview = null;
    aiFindings = [];
  }
}
```

**Error Tolerance:**
- AI failures are **silently caught**
- Analysis continues with deterministic results only
- Report still generated successfully
- `aiReview` field set to `null` in final report

**AI Review Content:**
- **Summary**: High-level analysis summary
- **Highlights**: Important findings with severity (info/warn/error)
- **Suggested Actions**: Prioritized recommendations (p0/p1/p2)
- **Limitations**: Known constraints (e.g., "MVP deterministic mode (no LLM)")

**DeterministicAiReviewService Behavior:**
- Currently generates AI review based on rule results (no LLM)
- Maps rule failures/warnings to AI highlights
- Provides structured suggestions
- Always succeeds (deterministic)

**Legacy AiReviewer Support:**
- If `aiReviewer` provided (not `NoopAiReviewer`), also calls legacy interface
- Merges legacy findings with new AI review findings
- Legacy failures also caught silently

### 6. Merge Findings

**Strategy:**
```dart
findings = _mergeFindings(
  deterministic: reportWithoutAi.findings,
  ai: aiFindings,
);
```

**Merge Rules:**
1. **Deterministic findings first**: Source of truth
2. **AI findings appended**: Complementary suggestions
3. **Deduplicate by ID**: Prevent duplicate findings

**Priority:**
- Deterministic findings always included
- AI findings are supplementary
- If AI fails, only deterministic findings remain

### 7. Build Final Report

**Final AicrReport:**
```dart
return AicrReport(
  meta: reportWithoutAi.meta,
  summary: reportWithoutAi.summary,
  rules: reportWithoutAi.rules,
  findings: mergedFindings,  // Deterministic + AI
  contracts: reportWithoutAi.contracts,
  files: reportWithoutAi.files,
  recommendations: reportWithoutAi.recommendations,
  aiReview: aiReview,  // null if AI disabled or failed
);
```

### 8. Render Output

#### JSON Format (`--format json`)
```dart
report.toPrettyJson()
```
- Complete machine-readable report
- Includes all metadata, rules, findings, AI review
- Suitable for CI/CD integration

#### PR Comment Format (`--format pr_comment`)
```dart
PrCommentRenderer().render(report, locale: language)
```
- Human-readable markdown
- Status summary table
- Review recommendation
- Top actionable findings
- Categorized findings list
- Suitable for GitHub/GitLab PR comments

## Error Tolerance & Fallbacks

### 1. File List Resolution

**Primary:** CLI-provided `FileEntry[]` (accurate change types)  
**Fallback:** Parse from diff text (all 'modified')

**Why:** `GitChangedFilesService` provides accurate change types, but not always available.

### 2. AI Review Failures

**Behavior:** Silent catch, continue without AI

**Rationale:** AI is supplementary. Deterministic rules are the source of truth.

**Test Coverage:** `test/aicr_engine_ai_failure_test.dart` verifies this behavior.

### 3. Git Command Failures

**Location:** CLI entry point

**Behavior:** Exit with error message (fails fast)

**Rationale:** Cannot proceed without diff text.

### 4. Rule Evaluation

**Behavior:** Rules always run, never throw

**Rationale:** Rules are deterministic and should never fail. If a rule has a bug, it should return `pass` rather than throw.

### 5. Report Building

**Behavior:** Always succeeds

**Rationale:** Report builder uses validated inputs and has sensible defaults.

## Key Design Principles

### 1. Single Entry Point

All analysis flows through `AicrEngine.analyze()`. This ensures:
- Consistent behavior
- Centralized error handling
- Predictable output format

### 2. Deterministic First

Deterministic rules are the source of truth. AI is always supplementary:
- Rules always run
- AI failures don't break analysis
- Findings merge: deterministic first, AI appended

### 3. Error Tolerance

Failures are handled gracefully:
- AI failures: Continue without AI
- Missing files: Fallback to diff parsing
- Invalid inputs: Fail fast with clear messages

### 4. Best Effort AI

AI layer is "best effort":
- Never throws exceptions
- Failures are silent
- Analysis always completes

## Example Flows

### Flow 1: AI OFF, Diff File Input

```
CLI → Parse args → Read diff file → Engine.analyze()
  → Resolve files (from diff) → Evaluate rules
  → Build report (no AI) → Render JSON → Output
```

### Flow 2: AI ON, Git Range, Success

```
CLI → Parse args → Git diff command → Engine.analyze()
  → Resolve files → Evaluate rules → Build initial report
  → AI review (success) → Merge findings → Build final report
  → Render PR comment → Output
```

### Flow 3: AI ON, AI Failure

```
CLI → Parse args → Git diff command → Engine.analyze()
  → Resolve files → Evaluate rules → Build initial report
  → AI review (throws) → Catch silently → Continue without AI
  → Merge findings (deterministic only) → Build final report
  → Render JSON → Output
```

### Flow 4: Git Name Status Mode

```
CLI → Parse args → Git name-status command → Get FileEntry[]
  → Git diff command → Get diffText → Engine.analyze()
  → Use provided FileEntry[] (accurate change types)
  → Evaluate rules → Build report → Render → Output
```

## Summary

AICR's flow is designed for reliability and error tolerance:

- **Single entry point** ensures consistency
- **Deterministic rules** are always the source of truth
- **AI is supplementary** and failures never break analysis
- **Fallbacks** ensure analysis completes even with partial inputs
- **Error tolerance** at every layer prevents cascading failures

The system prioritizes completing analysis over perfect accuracy, making it suitable for CI/CD environments where partial results are better than no results.



