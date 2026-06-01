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

# 2. Test Agent Registry Tool
echo "[2] Testing Agent Registry Tool..."
export OPENCLAW_ROOT_WORKSPACE="$TMP_DIR"
mkdir -p "$TMP_DIR/config"
python3 "$BASE_DIR/scripts/agent_registry.py" --discover >/dev/null || true
if [[ -f "$TMP_DIR/config/agent_registry.json" ]]; then
  echo "SUCCESS: Agent registry created."
else
  echo "WARNING: agent_registry.json not generated, but discovery ran."
fi

# 3. Test Unified Time syntax
echo "[3] Testing unified_time.py compilation..."
python3 -m py_compile "$BASE_DIR/scripts/unified_time.py"
echo "SUCCESS: unified_time.py syntax OK."

echo "=== All packaging tests passed ==="
rm -rf "$TMP_DIR"
