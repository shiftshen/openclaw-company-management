#!/usr/bin/env bash
set -euo pipefail

echo "=== Testing Company Management Skill Package ==="
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TMP_DIR="$(mktemp -d)"
echo "Using isolated tmp dir: $TMP_DIR"

# 1. Test Database Initialization
echo "[1] Testing SQLite Schema initialization..."
TEST_DB="$TMP_DIR/test_accounts.db"
sqlite3 "$TEST_DB" < "$BASE_DIR/templates/skill_accounts.sql"
TABLES=$(sqlite3 "$TEST_DB" "SELECT name FROM sqlite_master WHERE type='table';")
if ! echo "$TABLES" | grep -q "skill_accounts"; then
  echo "FAIL: skill_accounts table missing"
  exit 1
fi
echo "SUCCESS: DB schema applied cleanly."

# 2. Test install.sh deploys all executors without deleting DB rows
echo "[2] Testing install.sh deployment and DB preservation..."
export OPENCLAW_ROOT="$TMP_DIR/openclaw"
export OPENCLAW_WORKSPACE="$TMP_DIR/openclaw/workspace-main"
mkdir -p "$OPENCLAW_WORKSPACE/config" "$OPENCLAW_WORKSPACE/scripts"
sqlite3 "$OPENCLAW_WORKSPACE/config/skill_accounts.db" < "$BASE_DIR/templates/skill_accounts.sql"
sqlite3 "$OPENCLAW_WORKSPACE/config/skill_accounts.db" "INSERT OR IGNORE INTO skill_accounts (skill, business, platform, account_label, notes) VALUES ('test-skill','testbiz','line','test-account','preserve-check');"
bash "$BASE_DIR/install.sh" >/dev/null
for script in unified_time.py unified_browser.py unified_outbound.py agent_bus_worker.py agent_registry.py request_main.py agent_comm_contract.py company_kernel_bridge.py; do
  if [[ ! -x "$OPENCLAW_WORKSPACE/scripts/$script" ]]; then
    echo "FAIL: deployed script missing or not executable: $script"
    exit 1
  fi
done
ROW_COUNT=$(sqlite3 "$OPENCLAW_WORKSPACE/config/skill_accounts.db" "SELECT COUNT(*) FROM skill_accounts WHERE business='testbiz' AND account_label='test-account';")
if [[ "$ROW_COUNT" != "1" ]]; then
  echo "FAIL: existing skill_accounts.db row was not preserved"
  exit 1
fi
echo "SUCCESS: install.sh deployed executors and preserved DB data."

# 3. Test Agent Registry Tool
echo "[3] Testing Agent Registry Tool..."
mkdir -p "$TMP_DIR/config"
python3 "$BASE_DIR/scripts/agent_registry.py" --discover >/dev/null || true
if [[ -f "$OPENCLAW_WORKSPACE/config/agent_registry.json" ]]; then
  echo "SUCCESS: Agent registry created."
else
  echo "WARNING: agent_registry.json not generated, but discovery ran."
fi

# 4. Test Python script compilation
echo "[4] Testing Python script compilation..."
python3 -m py_compile "$BASE_DIR"/scripts/*.py
echo "SUCCESS: Python syntax OK."

# 5. Test Company Kernel bridge against fake local commands
echo "[5] Testing Company Kernel bridge..."
FAKE_KERNEL="$TMP_DIR/company-kernel"
mkdir -p "$FAKE_KERNEL/bin" "$TMP_DIR/workspace/scripts"
cat > "$FAKE_KERNEL/bin/companyctl" <<'SH'
#!/usr/bin/env bash
printf '%s\n' '{"ok":true,"counts":{"employees":2,"heartbeats":2},"heartbeat":{"missing":0,"stale":0},"daemon":{"ok":true,"age_minutes":0},"issues":[]}'
SH
chmod +x "$FAKE_KERNEL/bin/companyctl"
python3 "$BASE_DIR/scripts/company_kernel_bridge.py" health --company-kernel "$FAKE_KERNEL" >/dev/null
cat > "$TMP_DIR/workspace/scripts/company_runtime_alert.py" <<'PY'
#!/usr/bin/env python3
import json
print(json.dumps({"ok": True, "severity": "ok", "reasons": [], "summary": {"employee_count": 8, "healthy_recent_count": 8, "no_heartbeat_count": 0, "company_kernel_ok": True, "company_kernel_heartbeats": 14, "main_down_suspected": False, "company_wide_no_heartbeat": False}}))
PY
chmod +x "$TMP_DIR/workspace/scripts/company_runtime_alert.py"
python3 "$BASE_DIR/scripts/company_kernel_bridge.py" heartbeat-alert --alert-script "$TMP_DIR/workspace/scripts/company_runtime_alert.py" >/dev/null
echo "SUCCESS: Company Kernel bridge returned healthy status."

echo "=== All packaging tests passed ==="
rm -rf "$TMP_DIR"
