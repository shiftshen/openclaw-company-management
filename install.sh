#!/usr/bin/env bash
set -euo pipefail

echo ">>> 开始部署 OpenClaw 公司管理技能包 (Company Management Skill)..."

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
XMANX_WORKSPACE="/Users/shift/openclaw/workspace-xmanx"

# 1. 数据库物理锁初始化
DB_DIR="$XMANX_WORKSPACE/config"
DB_PATH="$DB_DIR/skill_accounts.db"
mkdir -p "$DB_DIR"
echo "-> 校验并加固底层数据库约束 ($DB_PATH)..."
sqlite3 "$DB_PATH" < "$BASE_DIR/templates/skill_accounts.sql"

# 2. 统一执行器分发
echo "-> 分发统一执行器..."
cp "$BASE_DIR/scripts/unified_time.py" "$XMANX_WORKSPACE/scripts/"
cp "$BASE_DIR/scripts/unified_browser.py" "$XMANX_WORKSPACE/scripts/"
cp "$BASE_DIR/scripts/unified_outbound.py" "$XMANX_WORKSPACE/scripts/"

# 3. 规程同步提示
echo "-> 员工入职规程已落盘至: $BASE_DIR/SKILL.md"
echo "-> 部署完成！整个机器已被收编为统一标准架构。"
