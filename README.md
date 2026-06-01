# OpenClaw Company Management

`openclaw-company-management` 是 OpenClaw 本机公司管理技能包，目标是把多业务、多账号、多 Agent 的执行方式收敛到可安装、可验证、可持续维护的工程标准。

本项目第三轮收尾后，已形成三条核心闭环：

1. 基础架构与环境闭环
   - `install.sh` 负责初始化 `skill_accounts.db` 表结构，并把统一执行器同步到目标 OpenClaw 工作区。
   - 脚本默认支持 `OPENCLAW_ROOT`、`OPENCLAW_WORKSPACE`、`OPENCLAW_AGENT_BUS` 等环境变量覆盖。
   - 在 Shift 本机环境下，默认自适应 `/Users/shift/openclaw/workspace-xmanx`，远端或其他机器仍可走标准 `${HOME}/openclaw/workspace-main`。

2. 业务管控闭环
   - `templates/skill_accounts.sql` 定义单源账号路由数据库 `skill_accounts.db`。
   - `scripts/skill_accounts_db.py` 提供账号注册、查询、状态更新、审计与路由能力。
   - `scripts/unified_browser.py` 和 `scripts/unified_outbound.py` 通过数据库路由选择业务账号，减少硬编码脚本路径。
   - `scripts/cleanup_trash.sh` 支持 03:00 定时零垃圾态清理，清理 `tmp`、`logs` 下过期调试/失败/补丁残留文件。

3. 通知闭环
   - `scripts/progress_report.py` 强制 Codex -> Main 使用 4 态汇报：`acknowledged`、`in_progress`、`blocked`、`completed`。
   - `scripts/request_main.py` 通过 agent registry 向 Main 提交结构化请求。
   - `scripts/agent_bus_worker.py` 负责读取 agent bus inbox、执行/确认任务并生成 receipt。
   - `scripts/agent_comm_contract.py` 统一强制字段校验，避免 blocker 与跨 Agent handoff 缺少执行证据。

## 安装

```bash
./install.sh
```

默认安装到：

- Shift 本机：`/Users/shift/openclaw/workspace-xmanx`
- 其他环境：`${HOME}/openclaw/workspace-main`

可用环境变量覆盖：

```bash
OPENCLAW_ROOT=/path/to/openclaw OPENCLAW_WORKSPACE=/path/to/workspace ./install.sh
```

## 关键命令

```bash
python3 scripts/skill_accounts_db.py list
python3 scripts/unified_time.py --target current
python3 scripts/progress_report.py --state completed --project openclaw-company-management --action "..." --checking "..."
bash scripts/cleanup_trash.sh
```

## 验证

```bash
python3 -m py_compile scripts/*.py
bash -n install.sh scripts/cleanup_trash.sh
python3 scripts/unified_time.py --target current
python3 scripts/progress_report.py --state completed --project openclaw-company-management --action "dry run" --checking "dry run"
```

`progress_report.py` 默认 dry-run；只有加 `--apply` 才会写入 `OPENCLAW_AGENT_BUS/inbox/main`。

## 交付状态

第三轮最终收尾完成后，本项目状态为 100% 结项：

- 基础架构与环境闭环已完成。
- 业务管控闭环已完成。
- Codex -> Main 通知闭环已完成。
- 核心业务逻辑未在本轮改变，仅做工程化收尾、文档对齐与脚本整理。
