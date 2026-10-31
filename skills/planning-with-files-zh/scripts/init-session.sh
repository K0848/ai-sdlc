#!/usr/bin/env bash
# 从 Skill 模板初始化项目台账
# 用法：./init-session.sh [项目名称]

set -e

PROJECT_NAME="${1:-project}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE_DIR="$SKILL_DIR/templates"
LEDGER_DIR="$(pwd)/.claude"

echo "正在初始化规划文件：$PROJECT_NAME"
mkdir -p "$LEDGER_DIR"

for name in task_plan.md findings.md progress.md; do
    source_file="$TEMPLATE_DIR/$name"
    target_file="$LEDGER_DIR/$name"
    if [ ! -f "$target_file" ]; then
        cp "$source_file" "$target_file"
        echo "已创建 .claude/$name"
    else
        echo ".claude/$name 已存在，跳过"
    fi
done

if [ ! -f "$LEDGER_DIR/changelog.md" ]; then
    printf '# 工作日志\n' > "$LEDGER_DIR/changelog.md"
    echo "已创建 .claude/changelog.md"
else
    echo ".claude/changelog.md 已存在，跳过"
fi

echo
echo "规划文件已初始化：.claude/task_plan.md、findings.md、progress.md、changelog.md"
