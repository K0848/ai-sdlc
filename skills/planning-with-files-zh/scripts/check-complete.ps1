# 报告 task_plan.md 的当前未完成任务和阻塞状态
# 始终以退出码 0 结束；未完成任务是正常状态

param(
    [string]$PlanFile = ".claude/task_plan.md"
)

if (-not (Test-Path -LiteralPath $PlanFile)) {
    Write-Host '[planning-with-files] 未找到 .claude/task_plan.md — 没有进行中的规划会话。'
    exit 0
}

function Get-SectionText {
    param([string]$Text, [string]$Heading)
    $Result = New-Object System.Collections.Generic.List[string]
    $Inside = $false
    foreach ($Line in ($Text -split "`r?`n")) {
        if ($Line -eq "## $Heading") {
            $Inside = $true
            continue
        }
        if ($Inside -and $Line.StartsWith('## ')) { break }
        if ($Inside) { $Result.Add($Line) }
    }
    return ($Result -join "`n")
}

$Content = Get-Content -LiteralPath $PlanFile -Raw -Encoding UTF8
$CurrentText = Get-SectionText -Text $Content -Heading '当前进行中'
$BlockerText = Get-SectionText -Text $Content -Heading '当前阻塞 / 待定'

if (-not $CurrentText) {
    Write-Host '[planning-with-files] task_plan.md 缺少“当前进行中”章节；请运行 check_ledgers.py 检查台账契约。'
    exit 0
}

$OpenCount = ([regex]::Matches($CurrentText, '(?m)^\s*-\s+\[\s\]\s+')).Count
$BlockerCount = @(
    [regex]::Matches($BlockerText, '(?m)^\s*-\s+.+$') |
        ForEach-Object { $_.Value.Trim() } |
        Where-Object { $_ -notmatch '^-\s*(无|没有|暂无)[。.]?$' }
).Count

if ($OpenCount -eq 0 -and $BlockerCount -eq 0) {
    Write-Host '[planning-with-files] 当前进行中没有未完成项且无阻塞；如任务已交付，请同步 changelog.md 和 progress.md。'
} else {
    Write-Host ("[planning-with-files] 任务进行中：当前未完成项 $OpenCount 个，阻塞/待定 $BlockerCount 个。停止前请更新 progress.md。")
}

if ((Test-Path '.claude/progress.md') -and (Test-Path '.claude/changelog.md')) {
    if ((Get-Item '.claude/progress.md').LastWriteTime -gt (Get-Item '.claude/changelog.md').LastWriteTime) {
        Write-Host '[planning-with-files-zh] progress.md 比 changelog.md 新；会话有实质工作时请同步追加到 changelog.md。'
    }
}

exit 0
