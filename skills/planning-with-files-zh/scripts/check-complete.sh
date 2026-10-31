#!/usr/bin/env bash
# 报告 task_plan.md 的当前未完成任务和阻塞状态
# 始终以退出码 0 结束；未完成任务是正常状态

PLAN_FILE="${1:-.claude/task_plan.md}"

if [ ! -f "$PLAN_FILE" ]; then
    echo "[planning-with-files] 未找到 .claude/task_plan.md — 没有进行中的规划会话。"
    exit 0
fi

section_text() {
    awk -v target="$1" '
        $0 == "## " target { active=1; next }
        active && /^## / { exit }
        active { print }
    ' "$PLAN_FILE"
}

CURRENT_TEXT="$(section_text '当前进行中')"
BLOCKER_TEXT="$(section_text '当前阻塞 / 待定')"

if [ -z "$CURRENT_TEXT" ]; then
    echo "[planning-with-files] task_plan.md 缺少‘当前进行中’章节；请运行 check_ledgers.py 检查台账契约。"
    exit 0
fi

OPEN_COUNT=$(printf '%s\n' "$CURRENT_TEXT" | grep -cE '^[[:space:]]*-[[:space:]]+\[[[:space:]]\][[:space:]]+' || true)
BLOCKER_COUNT=$(printf '%s\n' "$BLOCKER_TEXT" | grep -E '^[[:space:]]*-[[:space:]]+.+' | grep -vcE '^[[:space:]]*-[[:space:]]*(无|没有|暂无)[。.]?$' || true)

if [ "$OPEN_COUNT" -eq 0 ] && [ "$BLOCKER_COUNT" -eq 0 ]; then
    echo "[planning-with-files] 当前进行中没有未完成项且无阻塞；如任务已交付，请同步 changelog.md 和 progress.md。"
else
    echo "[planning-with-files] 任务进行中：当前未完成项 $OPEN_COUNT 个，阻塞/待定 $BLOCKER_COUNT 个。停止前请更新 progress.md。"
fi

if [ -f .claude/progress.md ] && [ -f .claude/changelog.md ] && [ .claude/progress.md -nt .claude/changelog.md ]; then
    echo "[planning-with-files-zh] progress.md 比 changelog.md 新；会话有实质工作时请同步追加到 changelog.md。"
fi

exit 0
