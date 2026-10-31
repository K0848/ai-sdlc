from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


class LedgerValidationError(ValueError):
    """Raised when a ledger contains historical content in a current-state file."""


PROGRESS_SECTIONS = (
    "当前状态",
    "最近关键进展",
    "当前风险 / 阻塞",
    "下一步",
    "验证状态",
)
PLAN_SECTIONS = {
    "当前目标",
    "当前进行中",
    "后续 Backlog",
    "已完成里程碑",
    "当前阻塞 / 待定",
    "维护规则",
}


def _level_two_headings(text: str) -> list[str]:
    return [
        match.group(1).strip()
        for match in re.finditer(r"^##\s+(.+?)\s*$", text, flags=re.MULTILINE)
    ]


def validate_progress_text(text: str) -> None:
    headings = _level_two_headings(text)
    for section_name in PROGRESS_SECTIONS:
        if headings.count(section_name) != 1:
            raise LedgerValidationError(
                f"progress.md 的‘{section_name}’标题必须恰好出现 1 次，实际为 {headings.count(section_name)} 次。"
            )
    unexpected = [heading for heading in headings if heading not in PROGRESS_SECTIONS]
    if unexpected:
        raise LedgerValidationError(
            "progress.md 含历史或不允许的二级标题：" + "、".join(unexpected)
        )


def validate_task_plan_text(text: str) -> None:
    headings = _level_two_headings(text)
    unexpected = [heading for heading in headings if heading not in PLAN_SECTIONS]
    if unexpected:
        raise LedgerValidationError(
            "task_plan.md 只能保留当前计划目录；请将以下历史条目迁入 archive/："
            + "、".join(unexpected)
        )
    for section in ("当前目标", "当前进行中", "后续 Backlog"):
        if headings.count(section) != 1:
            raise LedgerValidationError(
                f"task_plan.md 的‘{section}’标题必须恰好出现 1 次，实际为 {headings.count(section)} 次。"
            )
    if headings.count("已完成里程碑") > 1:
        raise LedgerValidationError("task_plan.md 的‘已完成里程碑’标题最多出现 1 次。")


def validate_file(path: Path, validator) -> None:
    validator(path.read_text(encoding="utf-8"))


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate the current-state contract for .claude project ledgers."
    )
    parser.add_argument("--root", type=Path, default=Path.cwd())
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    ledger_dir = args.root.resolve() / ".claude"
    try:
        validate_file(ledger_dir / "task_plan.md", validate_task_plan_text)
        validate_file(ledger_dir / "progress.md", validate_progress_text)
    except (OSError, LedgerValidationError) as exc:
        print(f"ledger validation failed: {exc}", file=sys.stderr)
        return 1
    print(f"ledger validation passed: {ledger_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
