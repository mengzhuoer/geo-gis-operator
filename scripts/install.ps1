<#
.SYNOPSIS
    安装 geo-gis-operator 技能到本机已检测到的 AI 编码工具。

.DESCRIPTION
    把仓库中的 .agents/skills/ 复制到各客户端扫描的技能目录。
    只做复制,不修改任何客户端的配置文件(MCP 配置请手动粘贴
    docs/MCP-CONFIG.md 里的片段)。

    幂等:重复运行只会覆盖同名技能目录。

.PARAMETER Target
    只安装到指定客户端。可重复指定。取值:
      claude | codex | cursor | vscode | copilot | gemini | windsurf | opencode | all
    省略则自动检测本机已安装的客户端。

.PARAMETER ProjectRoot
    项目级安装的目标根目录(默认当前目录)。
    项目级安装会创建 <root>/.agents/skills 以及各客户端的本地目录。

.EXAMPLE
    .\scripts\install.ps1
    自动检测并安装到所有已发现的客户端。

.EXAMPLE
    .\scripts\install.ps1 -Target claude,codex
    只装到 Claude Code 与 Codex。
#>
[CmdletBinding()]
param(
    [string[]]$Target = @(),
    [string]$ProjectRoot = (Get-Location).Path,
    [switch]$UserScope,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }
$OutputEncoding = [System.Text.Encoding]::UTF8

$SkillSource = Join-Path (Split-Path -Parent $PSScriptRoot) '.agents\skills'
if (-not (Test-Path $SkillSource)) {
    Write-Error "找不到技能源目录: $SkillSource"
}

$SkillNames = Get-ChildItem $SkillSource -Directory | Select-Object -ExpandProperty Name

# client -> @{ User = @(...); Project = @(...) }
$Clients = @{
    'claude'   = @{ User   = @('~/.claude/skills')
                   Project = @('.claude/skills') }
    'codex'    = @{ User   = @('~/.codex/skills')
                   Project = @('.codex/skills') }
    'cursor'   = @{ User   = @('~/.cursor/skills', '~/.agents/skills')
                   Project = @('.cursor/skills', '.agents/skills') }
    'vscode'   = @{ User   = @('~/.copilot/skills')
                   Project = @('.github/skills', '.agents/skills') }
    'copilot'  = @{ User   = @('~/.copilot/skills')
                   Project = @('.github/skills', '.agents/skills') }
    'gemini'   = @{ User   = @('~/.gemini/skills', '~/.agents/skills')
                   Project = @('.gemini/skills', '.agents/skills') }
    'windsurf' = @{ User   = @('~/.codeium/windsurf/skills', '~/.agents/skills')
                   Project = @('.agents/skills') }
    'opencode' = @{ User   = @('~/.config/opencode/skills', '~/.agents/skills')
                   Project = @('.opencode/skills', '.agents/skills') }
}

function Test-ClientInstalled {
    param([string]$name)
    $userHome = $env:USERPROFILE
    switch ($name) {
        'claude'   { return (Test-Path "$userHome\.claude") -or (Get-Command claude -ErrorAction SilentlyContinue) }
        'codex'    { return (Test-Path "$userHome\.codex") -or (Get-Command codex -ErrorAction SilentlyContinue) }
        'cursor'   { return (Test-Path "$userHome\.cursor") }
        'vscode'   { return (Test-Path "$env:APPDATA\Code") }
        'copilot'  { return (Test-Path "$userHome\.copilot") }
        'gemini'   { return (Test-Path "$userHome\.gemini") -or (Get-Command gemini -ErrorAction SilentlyContinue) }
        'windsurf' { return (Test-Path "$userHome\.codeium\windsurf") }
        'opencode' { return (Test-Path "$userHome\.config\opencode") }
        default    { return $false }
    }
}

function Expand-Tilde {
    param([string]$p)
    if ($p.StartsWith('~')) {
        return Join-Path $env:USERPROFILE $p.Substring(2)
    }
    return $p
}

# ---- 决定目标客户端 ----
if ($Target -contains 'all') {
    $chosen = @($Clients.Keys | Sort-Object)
} elseif ($Target.Count -gt 0) {
    $chosen = @()
    foreach ($t in $Target) {
        if (-not $Clients.ContainsKey($t)) { Write-Error "未知客户端: $t(可选: $($Clients.Keys -join ', '))" }
        $chosen += $t
    }
} else {
    $chosen = @($Clients.Keys | Where-Object { Test-ClientInstalled $_ } | Sort-Object)
}

if ($chosen.Count -eq 0) {
    Write-Host 'No supported AI coding client detected.' -ForegroundColor Yellow
    Write-Host 'Manual install: copy the skill folders under .agents\skills\ into your client''s skills directory.'
    Write-Host 'Per-client directory map: docs\PORTABILITY.md'
    exit 0
}

Write-Host "Skill source : $SkillSource"
Write-Host "Skills       : $($SkillNames.Count)"
Write-Host "Targets      : $($chosen -join ', ')"
Write-Host ''

$installed = @()
$seenDirs = @{}   # de-dup: several clients share the same target directory

foreach ($client in $chosen) {
    $dirs = if ($UserScope) { $Clients[$client].User } else { $Clients[$client].Project }
    foreach ($d in $dirs) {
        $full = if ($d.StartsWith('~')) { Expand-Tilde $d } else { Join-Path $ProjectRoot $d }
        $key = $full.ToLowerInvariant()
        if ($seenDirs.ContainsKey($key)) { continue }
        $seenDirs[$key] = $client

        foreach ($skill in $SkillNames) {
            $dest = Join-Path $full $skill
            if ($DryRun) {
                Write-Host "  [dry-run] $skill -> $dest" -ForegroundColor DarkGray
                continue
            }
            New-Item -ItemType Directory -Force -Path $full | Out-Null
            if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
            Copy-Item -Recurse -Force (Join-Path $SkillSource $skill) $dest
        }
        if (-not $DryRun) {
            Write-Host ("  [ok] {0,-10} -> {1}" -f $client, $full) -ForegroundColor Green
            $installed += [pscustomobject]@{ Client = $client; Path = $full }
        }
    }
}

if (-not $DryRun) {
    Write-Host ''
    Write-Host 'Install complete.' -ForegroundColor Green
    Write-Host ''
    Write-Host 'Next steps:'
    Write-Host '  1. Wire up the MCP server -- paste the snippet from docs/MCP-CONFIG.md'
    Write-Host '     (this script never edits client config files -- paste it yourself)'
    Write-Host '  2. Start a new session; the skills are then discovered'
    Write-Host '  3. Run from the project root for project scope; add -UserScope for user scope'
}
