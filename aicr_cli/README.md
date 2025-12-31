# AICR — AI Code Reviewer

AICR (AI Code Reviewer) is a command-line tool that analyzes code changes in Flutter + BLoC repositories. It provides deterministic rule-based analysis with optional AI-assisted explanations and suggestions.

## Features

- **Deterministic Rule Engine**: Analyzes code changes against a set of predefined rules
- **Optional AI Review**: Provides AI-generated explanations and suggestions (non-authoritative)
- **Multiple Input Sources**: Supports git diff, file-based diff, and git range analysis
- **Flexible Output Formats**: JSON reports and PR comment markdown
- **Bilingual Support**: Turkish and English language support

## Rules

AICR includes the following deterministic rules:

- **BLoC Change Requires Tests**: Detects when BLoC files change and expects corresponding tests
- **Secret/Env Exposure**: Warns about potential secret or environment variable exposure
- **Large Change Set**: Flags when too many files are changed in a single PR
- **Layer Violation**: Detects architecture layer violations (e.g., presentation importing data layer)
- **UI Change Suggests Golden Tests**: Recommends golden tests for UI changes
- **Large Diff Suggests Split**: Suggests splitting large diffs into smaller changes

## Installation

```bash
# Clone the repository
git clone <repository-url>
cd flutter-aicr/aicr_cli

# Install dependencies
dart pub get

# Build generated code
dart run build_runner build --delete-conflicting-outputs
```

## Usage

### Basic Command Structure

```bash
dart run bin/aicr_cli.dart [options]
```

### Command-Line Options

- `--repo` (optional): Repository name (defaults to directory name)
- `--repo-path` (optional): Local repository path (defaults to current directory)
- `--mode` (optional): Analysis mode - `git_diff` or `git_name_status` (default: `git_diff`)
- `--range` (optional): Git range (e.g., `origin/main...HEAD`)
- `--diff` (optional): Path to diff text file
- `--out` (optional): Output file path (default: `tmp/report.json`)
- `--format` (optional): Output format - `json` or `pr_comment` (default: `json`)
- `--ai` (flag): Enable AI review (default: `false`)
- `--lang` (optional): Language - `en` or `tr` (default: `en`)

## Usage Examples

### Example 1: Analyze from Diff File

Analyze code changes from a saved diff file:

```bash
dart run bin/aicr_cli.dart \
  --repo my-flutter-app \
  --diff test/fixtures/sample.diff \
  --out reports/analysis.json \
  --format json
```

**Output Example (JSON):**

```json
{
  "meta": {
    "tool": {
      "name": "AICR",
      "version": "1.0.0"
    },
    "run_id": "aicr_123456789012345",
    "created_at": "2025-01-01T00:00:00.000Z",
    "repo": {
      "name": "my-flutter-app"
    },
    "input": {
      "diff_type": "git_diff",
      "diff_hash": "sha256:abc123",
      "file_count": 5
    },
    "ai": {
      "enabled": false
    }
  },
  "summary": {
    "status": "pass",
    "rule_results": {
      "pass": 4,
      "warn": 1,
      "fail": 0
    },
    "contract_results": {
      "pass": 0,
      "warn": 0,
      "fail": 0
    },
    "file_findings": {
      "info": 0,
      "warn": 0,
      "error": 0
    }
  },
  "rules": [
    {
      "rule_id": "bloc_change_requires_tests",
      "status": "pass",
      "title": "BLoC changes require tests",
      "message": {
        "tr": "BLoC değişiklikleri için testler mevcut.",
        "en": "Tests are present for BLoC changes."
      },
      "evidence": []
    }
  ],
  "findings": [],
  "files": [
    {
      "path": "lib/src/features/auth/auth_bloc.dart",
      "change_type": "modified"
    }
  ]
}
```

### Example 2: Analyze Local Repository with Git Range

Analyze changes between two git commits in a local repository:

```bash
dart run bin/aicr_cli.dart \
  --repo my-flutter-app \
  --repo-path /path/to/repo \
  --mode git_name_status \
  --range origin/main...HEAD \
  --ai \
  --lang en \
  --out reports/pr-analysis.json
```

This command:
- Analyzes changes between `origin/main` and `HEAD`
- Uses `git_name_status` mode to get accurate file change types
- Enables AI review for additional insights
- Outputs in English
- Saves results to `reports/pr-analysis.json`

### Example 3: Generate PR Comment Format

Generate a markdown-formatted PR comment:

```bash
dart run bin/aicr_cli.dart \
  --repo my-flutter-app \
  --repo-path . \
  --range origin/main...feature/new-auth \
  --format pr_comment \
  --ai \
  --lang en \
  --out pr-comment.md
```

**Output Example (PR Comment Markdown):**

```markdown
## AICR — PASS

**Repo:** my-flutter-app · **Run:** aicr_1234567890 · **Files:** 5 · **AI:** ON

| Signal | Pass | Warn | Fail |
|--------|------|------|------|
| Deterministic | 4 | 1 | 0 |
| AI (findings) | - | 2 | - |

### Review recommended
🟨 **Recommended** — warnings detected.

### Top actions
**Large change set detected** (AI, 85%) — Consider splitting this PR into smaller changes
**BLoC changes require tests** — Add tests for modified BLoC files

### All findings
**quality**
- `warning` **Large change set detected** — 15 files changed, consider splitting
- `suggestion` **UI changes suggest golden tests** — Consider adding golden tests for UI changes

**testing**
- `warning` **BLoC changes require tests** — Modified BLoC files should have corresponding tests
```

## Output Formats

### JSON Format

The JSON format provides a complete machine-readable report with:
- Metadata (tool version, run ID, timestamp)
- Summary (status, rule results, contract results)
- Detailed rule evaluations
- Findings (warnings, suggestions, errors)
- Changed files list
- Optional AI review section

### PR Comment Format

The PR comment format generates markdown suitable for:
- GitHub PR comments
- GitLab merge request discussions
- Code review platforms

It includes:
- Status summary
- Rule results table
- Review recommendation
- Top actionable findings
- Categorized findings list

## AI Review

When `--ai` flag is enabled, AICR generates additional insights:

- **Highlights**: Important code patterns and potential issues
- **Suggested Actions**: Prioritized recommendations (p0, p1, p2)
- **Limitations**: Known constraints of the AI analysis

**Note**: AI review is non-authoritative. The deterministic rule engine provides the source of truth.

## CI/CD Integration

### GitHub Actions

AICR can be integrated into your GitHub Actions workflow to generate PR comments automatically.

#### Setup

1. Copy the workflow file to your repository:
   ```bash
   cp .github/workflows/aicr-pr-comment.yml <your-repo>/.github/workflows/
   ```

2. The workflow runs automatically on PR events (opened, synchronize, reopened).

3. To enable AI review in CI (optional):
   - Go to your repository Settings → Secrets and variables → Actions
   - Add a new secret named `AICR_ENABLE_AI` with value `true`
   - The workflow will use AI review when this secret is set

#### Local Testing

You can test the PR comment generation locally using the same commands that the CI workflow uses:

```bash
# Basic PR comment generation (without AI)
cd aicr_cli
dart run bin/aicr_cli.dart \
  --repo your-repo-name \
  --repo-path . \
  --mode git_name_status \
  --range origin/main...HEAD \
  --format pr_comment \
  --lang en \
  --out pr_comment.md

# With AI enabled
dart run bin/aicr_cli.dart \
  --repo your-repo-name \
  --repo-path . \
  --mode git_name_status \
  --range origin/main...HEAD \
  --format pr_comment \
  --ai \
  --lang en \
  --out pr_comment.md
```

**Environment Variables (for local testing):**

You can simulate the CI environment by setting environment variables:

```bash
# Disable AI (default)
export AICR_AI=false
dart run bin/aicr_cli.dart --format pr_comment --range origin/main...HEAD

# Enable AI via environment variable (simulating CI secret)
export AICR_AI=true
dart run bin/aicr_cli.dart --format pr_comment --ai --range origin/main...HEAD
```

**Note**: The CLI uses the `--ai` flag directly. The `AICR_AI` environment variable in CI is used by the workflow script to conditionally pass the `--ai` flag to the CLI.

#### Workflow Output

The workflow generates a `pr_comment.md` file as an artifact that contains:
- Status summary
- Risk level and confidence
- Signals table
- Review recommendation
- Top actionable findings
- Categorized findings (AI and deterministic)

The artifact is available in the Actions tab of your PR for 7 days.

## Development

### Running Tests

```bash
dart test
```

### Code Generation

After modifying Freezed models or JSON serialization:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Code Analysis

```bash
dart analyze
```

## License

[Add your license information here]

## Contributing

[Add contribution guidelines here]
