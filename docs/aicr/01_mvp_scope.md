# AICR-001 — MVP Scope (v0.1)
**Project:** AICR (AI Code Reviewer / Refactor Assistant)  
**Focus:** Flutter + BLoC repos  
**Goal:** Production-minded prototype (not a commercial product yet)

> TR: Bu repo “satılan ürün” değil; ama prod düşünceyle tasarlanmış bir prototip.  
> EN: Not a SaaS yet, but designed with production principles (contracts, tests, extensibility).

---

## 1) Purpose
TR: Flutter+BLoC codebase’lerinde bir PR/diff değişimini analiz edip **deterministic** sonuç üretmek.  
EN: Analyze PR/diff changes and produce deterministic, machine-readable results.

**Outputs:**
- Rule checks (deterministic)
- API contract checks (deterministic)
- Optional LLM-assisted explanations (non-authoritative)

---

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
3) Optional LLM Assist for explanations/suggestions (**NOT the source of truth**)

> TR: Kararı kurallar verir. LLM sadece açıklar/önerir.  
> EN: Rules decide; LLM explains.

---

## 3) What MVP Explicitly Excludes (for now)
- Multi-tenant SaaS, billing, user accounts
- Full-repo deep scan (MVP is diff-first)
- Auto PR commenting / auto code changes
- Heavy auth and enterprise-grade compliance

---

## 4) MVP Rules (v0.1) — Flutter+BLoC oriented
> TR: Kural ID’leri İngilizce ve stabil. Açıklamalar çift dilli.

1) **rule_id:** `bloc_change_requires_tests`  
   TR: `*_bloc/*_event/*_state` değiştiyse ilgili testler beklenir.  
   EN: If BLoC files change, corresponding tests are expected.

2) **rule_id:** `breaking_change_detection`  
   TR: Public API yüzeyi değiştiyse breaking-change işaretlenir.  
   EN: Detect public API surface changes (mark as breaking).

3) **rule_id:** `contract_alignment_for_dtos`  
   TR: Endpoint/DTO değişimi contract ile uyuşmalı (alanlar/required).  
   EN: DTO changes must align with the contract.

4) **rule_id:** `serialization_conventions`  
   TR: Model/DTO serialization disiplini (fromJson/toJson pattern).  
   EN: Enforce serialization conventions.

5) **rule_id:** `no_data_layer_import_in_presentation`  
   TR: UI/Presentation katmanı data-source’a direkt import yapamaz.  
   EN: Presentation must not import data sources directly.

6) **rule_id:** `bloc_side_effects_flagging`  
   TR: BLoC içinde test zorlayan side-effect’leri işaretle (print, clock).  
   EN: Flag non-test-friendly side effects in BLoC.

7) **rule_id:** `l10n_no_hardcoded_strings`  
   TR: UI’da hardcoded kullanıcı metinlerini flagle (heuristic).  
   EN: Flag hardcoded user-facing strings (heuristic).

8) **rule_id:** `routing_changes_require_smoke_note`  
   TR: Routing değiştiyse smoke test notu düş.  
   EN: Route changes should trigger a smoke test note.

9) **rule_id:** `error_handling_discipline`  
   TR: Raw throw’ları flagle; domain failure yaklaşımı beklenir.  
   EN: Flag generic throws; prefer domain failures.

10) **rule_id:** `naming_and_structure_conventions`  
   TR: Dosya/folder naming ve yapı konvansiyonları.  
   EN: Enforce naming and structure conventions.

---

## 5) Contract Format (MVP)
TR: MVP, minimal JSON contract ile başlar; sonra OpenAPI’ye evrilebilir.  
EN: Start with minimal JSON contract; evolve to OpenAPI later.

Planned path: `contracts/api_contract.min.json`

---

## 6) Report Schema (MVP)
- JSON Schema path (planned): `schemas/aicr_report.schema.json`
- Sample report (planned): `examples/report.sample.json`

---

## 7) UI Screens (planned, later phase)
1) Report List
2) Report Detail
3) Run Analysis (paste diff)
4) Settings (LLM assist on/off, budget)

---

## 8) Key Principle
**Rules and contracts are the source of truth.**  
LLM (if used) only explains and suggests fixes; it does not decide pass/fail.
