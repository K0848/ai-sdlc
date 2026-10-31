# 从 Skill 模板初始化项目台账
# 用法：.\init-session.ps1 [项目名称]

param(
    [string]$ProjectName = "project"
)

$SkillRoot = Split-Path -Parent $PSScriptRoot
$TemplateDir = Join-Path $SkillRoot "templates"
$LedgerDir = Join-Path (Get-Location) ".claude"

Write-Host "正在初始化规划文件：$ProjectName"
New-Item -ItemType Directory -Force -Path $LedgerDir | Out-Null

foreach ($Name in @("task_plan.md", "findings.md", "progress.md")) {
    $Source = Join-Path $TemplateDir $Name
    $Target = Join-Path $LedgerDir $Name
    if (-not (Test-Path -LiteralPath $Target)) {
        Copy-Item -LiteralPath $Source -Destination $Target
        Write-Host "已创建 .claude/$Name"
    } else {
        Write-Host ".claude/$Name 已存在，跳过"
    }
}

$Changelog = Join-Path $LedgerDir "changelog.md"
if (-not (Test-Path -LiteralPath $Changelog)) {
    Set-Content -LiteralPath $Changelog -Value "# 工作日志`r`n" -Encoding UTF8
    Write-Host "已创建 .claude/changelog.md"
} else {
    Write-Host ".claude/changelog.md 已存在，跳过"
}

Write-Host ""
Write-Host "规划文件已初始化：.claude/task_plan.md、findings.md、progress.md、changelog.md"
