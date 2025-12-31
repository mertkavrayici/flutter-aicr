## Bot Integration Plan (GitHub + GitLab)

### GitHub PR comment akışı (Checks/Run + Comment)
- **Trigger**
  - `pull_request` (opened, synchronize, reopened) + opsiyonel `workflow_dispatch`
- **Adımlar**
  - **Checkout**: PR branch’i çek.
  - **Diff fetch**:
    - Tercih: GitHub API ile PR files + patch (küçük PR’larda)
    - Alternatif: `git fetch` + `git diff base...head` (büyük PR’larda daha stabil)
  - **AICR çalıştır**:
    - `aicr_cli` → JSON output (artifact) + PR comment (markdown)
    - `--ai` opsiyonel; `--ai-mode noop|fake` (prod default: noop)
  - **Check/Status yayınla**:
    - Deterministic sonuçtan “pass/warn/fail” üret.
    - “fail” ise check “failure”, aksi “success”/“neutral”.
  - **PR comment yayınla**:
    - Tek bir “sticky comment” stratejisi (mevcut bot comment’ini update et).
    - Comment içeriği: meta + decision + top actions + findings + confidence.

### GitLab MR note akışı
- **Trigger**
  - Pipeline: MR event (merge_request pipelines) veya “manual job”
- **Adımlar**
  - **Checkout**: MR source branch’i çek.
  - **Diff fetch**:
    - Tercih: GitLab API `merge_requests/:iid/changes` (dosya listesi + diff)
    - Alternatif: `git fetch` + `git diff target...source`
  - **AICR çalıştır**:
    - JSON artifact + MR note (markdown)
  - **MR note yayınla**:
    - “sticky note” gibi davranmak için: önce önceki bot notunu bul → update et (yoksa create).
  - **Pipeline status**:
    - Deterministic “fail” varsa job’ı fail ettir (gate), warn’da job pass ama note’da “Recommended”.

### Token / permissions gereksinimleri
- **GitHub**
  - `pull-requests: read` (diff/metadata)
  - `checks: write` (check run)
  - `contents: read` (checkout için)
  - `issues: write` (PR comment; PR’lar issue API ile)
- **GitLab**
  - `api` scope (MR changes + MR notes)
  - Repo read (checkout/fetch)
- **Gizli bilgiler**
  - Token’lar sadece CI secret store’da.
  - Bot hiçbir zaman diff içine token yazmaz; log’larda maskeleme zorunlu.

### Rate limit / caching / diff fetch stratejisi
- **Rate limit**
  - API çağrılarını minimize et: tek seferde MR/PR değişiklikleri + comment update.
  - Retry/backoff: 429/5xx için exponential backoff.
- **Caching**
  - Cache key: `repo + base_sha + head_sha` (veya diff hash)
  - Cache output: JSON report + rendered markdown
  - Aynı SHA’larda yeniden çalıştırmayı atla (no-op) veya sadece comment refresh.
- **Diff fetch**
  - Küçük değişiklik: API patch yeterli.
  - Büyük değişiklik: git diff (local) daha güvenilir; API truncation riskine dikkat.
  - File list her zaman saklanır (meta’da file_count + files[]).

### Bizim farkımız (kısa)
- **Deterministic gate**: kurallar net; “fail” merge’i bloklayabilir.
- **AI assist**: sadece yardımcı; tek başına kararı yükseltmez.
- **Repo policy**: `lib/src/**` gibi alanlarda dokümantasyon beklentisi, layer ihlali, secret sızıntısı vb.
- **Tek format**: GitHub/GitLab aynı markdown + aynı JSON schema.
- **Confidence**: her koşulda 0–100 skor; deterministic ağırlıklı, AI küçük modifier.


