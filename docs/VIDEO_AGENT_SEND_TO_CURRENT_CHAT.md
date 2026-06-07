# Video Agent Send-To-Current-Chat Governance

Updated: 2026-06-07

## Decision

All video employees must use one canonical media delivery command when sending completed videos or files back to Shift.

Canonical local script:

```bash
python3 /Users/shift/openclaw/scripts/video_send_current_chat.py \
  --agent <video-creator|video-ops|video-publisher> \
  --media <absolute_file_path> \
  --message "<short caption>" \
  --json
```

## Account Mapping

- `video-creator` -> Telegram account `video_creator`
- `video-ops` -> Telegram account `video_ops`
- `video-publisher` -> Telegram account `video_publisher`

Default target:

- Shift direct Telegram chat `6066269036`

## Rules

- A file path reply is not delivery.
- `已发`, `完成`, or `好了` is allowed only after the canonical script returns `ok: true`.
- If delivery fails, the agent must show the script result evidence and say the file is ready but direct send failed.
- Do not create separate Telegram senders inside creator, ops, or publisher workspaces.
- The canonical script stages media into `/Users/shift/openclaw/workspace-xmanx/outputs/delivery/` before sending.

## Local Runtime Evidence

Validated on 2026-06-07:

- `video-creator` real media send: `ok=true`, message id `5118`
- `video-ops` real media send: `ok=true`, message id `4024`
- `video-publisher` real media send: `ok=true`, message id `1706`
- Audit script: `/Users/shift/openclaw/scripts/video_send_current_chat_audit.py`
- Audit report: `/Users/shift/openclaw/reports/video-send-current-chat-audit-latest.json`

## Verification

```bash
python3 /Users/shift/openclaw/scripts/video_send_current_chat_audit.py

python3 /Users/shift/openclaw/scripts/video_send_current_chat.py \
  --agent video-ops \
  --media /absolute/path/to/video.mp4 \
  --message "delivery smoke" \
  --dry-run \
  --json
```

Expected:

- audit `ok=true`
- all three video workspaces mention the canonical script
- dry-run uses the intended Telegram account for the selected agent
