# AICR-001 — MVP Scope (v0.1)
**Project:** AICR (AI Code Reviewer / Refactor Assistant)  
**Focus:** Flutter + BLoC repos  
**Goal:** Production-minded prototype (not a commercial product yet)

## 1) Purpose
Analyze a Git diff/PR change-set for a Flutter+BLoC codebase and produce a deterministic, machine-readable report:
- rule checks (deterministic)
- API contract checks (deterministic)
- optional LLM-assisted explanations (non-authoritative)

## 2) What MVP Includes
### 2.1 Inputs
- Git diff text (primary)
- Optional: minimal API contract file (JSON)

### 2.2 Outputs
- `report.json` following a stable JSON Schema
- CLI summary output

### 2.3 Analysis Layers
1) Deterministic Rule Engine (no LLM required)
2) Contract Checker (no LLM required)
3) Optional LLM Assist for explanations/suggestions (NOT the source of truth)

## 3) What MVP Explicitly Excludes (for now)
- multi-tenant SaaS, billing, user accounts
- full-repo deep scan (MVP is diff-first)
- auto PR commenting / auto code changes
- heavy auth and enterprise-grade compliance

## 4) MVP Rules (v0.1) — Flutter+BLoC oriented
1) BLoC change implies tests: if `*_bloc/*_event/*_state` changes, require matching tests.
2) Public API surface change detection (breaking-change flag).
3) New/changed endpoint/DTO must match contract (fields/required fields).
4) DTO/model serialization discipline (fromJson/toJson presence and naming patterns).
5) Presentation/UI layer must not import data-source directly.
6) Flag non-test-friendly side effects in BLoC (prints, direct clocks, etc.).
7) L10n discipline: avoid hardcoded user-facing strings in UI (heuristic).
8) Routing changes trigger a “smoke test required” note.
9) Error handling discipline: avoid raw generic throws where domain failures expected.
10) File/folder naming conventions (snake_case, core/features structure).

## 5) Contract Format (MVP)
MVP starts with a minimal JSON contract (upgradeable to OpenAPI later).
Contract file path (planned): `contracts/api_contract.min.json`

## 6) Report Schema (MVP)
- JSON Schema path (planned): `schemas/aicr_report.schema.json`
- Sample report (planned): `examples/report.sample.json`

## 7) UI Screens (planned, later phase)
1) Report List
2) Report Detail
3) Run Analysis (paste diff)
4) Settings (LLM assist on/off, budget)

## 8) Key Principle
**Rules and contracts are the source of truth.**  
LLM (if used) only explains and suggests fixes; it does not decide pass/fail.
