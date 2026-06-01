# Project State: OpenClaw Company Management

## North-Star Goal
完善和开发 `openclaw-company-management` 项目。
此项目是 OpenClaw 核心公司管理技能包，涵盖统一执行器、单源数据库约束、员工入职规程及垃圾清理准则。
测试与部署目标仅限 `192.168.1.83`，严禁修改当前本地机器环境。

## Repository
`/Users/shift/openclaw/workspace-xmanx/projects/openclaw-company-management`

## Test Environment
`192.168.1.83` (ssh)
*注意：目前缺乏直接可用的 ssh credentials/alias，需在可用前绕过或隔离测试环境准备。*

## Active Owner
- Supervisor: `main` (OpenClaw)
- Implementer: `Codex`

## Current Stage
1. 将 192.168.1.83 作为测试靶机，交由 Codex 进行验证、部署和更新。
2. （当前）启动 目标与计划模式，由 Codex 自主分析工作区差异（workspace-main vs workspace-xmanx），制定修复与统一部署策略，并在本地代码更新后提交至 GitHub。

## Latest Evidence
- Codex 完成了 `task-002`。发现远端 192.168.1.83 使用的工作区为 `workspace-main`，且部署脚本仅同步了3个脚本，缺失 `agent_bus_worker.py` 等3个核心脚本。
- 远端的 `openclaw` CLI 未在 PATH 中。

## Blocker
- 远端目录约定（workspace-main）与本地（workspace-xmanx）有差异，需要统一设计部署逻辑。

## Next Action
- 下发 `task-003.md`，开启目标与计划模式：要求 Codex 修复脚本差异，更新 install.sh 使其自适应远端工作区，然后将成果推送到 GitHub，最后在 192.168.1.83 执行应用测试。
