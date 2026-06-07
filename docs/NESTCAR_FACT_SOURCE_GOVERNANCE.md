# NestCar Fact Source Governance

Updated: 2026-06-07

## Decision

NestCar business facts use PostgreSQL `nestour_ai` as the primary source of truth.

Local SQLite is retained only for:

- legacy migration reference
- local recognition queue/cache
- temporary smoke tests
- rollback/debug evidence

Qdrant is retained only for semantic retrieval and evidence pointers. It must not be used as a final business status store.

## Runtime Boundary

The production report and operational status should follow this source order:

1. PostgreSQL `nestour_ai`
2. local raw archives and direct NAS sync evidence
3. Qdrant semantic index pointers
4. legacy SQLite/JSON only as labelled fallback or debug evidence

Reports must not claim PostgreSQL as the main source while reading business statistics from SQLite or JSON.

## Current Local Implementation

The local OpenClaw NestCar workspace now has:

- `workspace-nestcar/scripts/build_line_file_business_daily.py`
  - PG-first daily report statistics
  - vehicle status from `nestour_ai.vehicles`
  - follow-up status from `nestour_ai.followup_tasks`
  - document intake status from `nestour_ai.document_intake_results`
  - LINE media status from `nestour_ai.files`
- `workspace-nestcar/scripts/nestcar_fact_source_guard.py`
  - verifies report sections are backed by PostgreSQL
  - writes `reports/nestcar-fact-source-guard-latest.json`
- `workspace-nestcar/scripts/daily_workflow.sh`
  - runs the fact-source guard after daily report generation
- Governance registry overlay
  - NestCar `fact_source = postgresql:nestour_ai`
  - SQLite role = `legacy_cache_and_recognition_queue_only`
  - Qdrant role = `semantic_pointer_only_not_business_truth`

## Verification Evidence

Latest validated state on 2026-06-07:

- PostgreSQL files: `5175`
- PostgreSQL vehicles: `31`
- PostgreSQL processing queue: `2432`
- Qdrant points after reconcile: `5175`
- Fact-source guard: `ok=true`
- Report fallback used: `[]`
- OpenClaw business-flow audit: `12/12`

## Required Checks

Run these on the OpenClaw host after changing NestCar reporting or recognition flow:

```bash
python3 /Users/shift/openclaw/workspace-nestcar/scripts/build_line_file_business_daily.py \
  --day "$(date +%F)" \
  --out "/Users/shift/openclaw/workspace-nestcar/reports/line-file-business-daily-$(date +%F).md"

python3 /Users/shift/openclaw/workspace-nestcar/scripts/nestcar_fact_source_guard.py \
  --day "$(date +%F)" \
  --json

cd "/Users/shift/openclaw/workspace-nestcar/projects/nestcar-ai-ops-file-system "
python3 -m nestour_ai.healthcheck \
  --out /Users/shift/openclaw/workspace-nestcar/reports/nestour-healthcheck-latest.json
```

Expected:

- fact-source guard `ok=true`
- all required sources start with `postgresql:`
- Qdrant count matches PostgreSQL files, or a reconcile report explains the delta

## Qdrant Rule

Qdrant should be reconciled from PostgreSQL, not from SQLite.

```bash
cd "/Users/shift/openclaw/workspace-nestcar/projects/nestcar-ai-ops-file-system "
python3 -m nestour_ai.qdrant_reconcile \
  --limit 200 \
  --out /Users/shift/openclaw/workspace-nestcar/reports/nestour-qdrant-reconcile-latest.json
```

If Qdrant is bound on a remote host loopback, use the local SSH tunnel endpoint such as `http://127.0.0.1:16333`.

## Prohibited Patterns

- Do not use SQLite counts as the official NestCar daily report source.
- Do not use Qdrant count as business completion status.
- Do not let SMB mount state block intake, OCR, VLM, report generation, or NAS direct sync.
- Do not report `ready_to_send` as `send_success`.
- Do not confirm payment, deposit, accident, insurance, fine, refund, or damage responsibility without human confirmation.
