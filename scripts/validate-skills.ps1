<#
.SYNOPSIS
    校验技能包是否符合 Agent Skills 开放规范。

.DESCRIPTION
    检查项:
      1. 每个技能目录含 SKILL.md
      2. frontmatter 是合法 YAML,且含 name / description
      3. name 为 1-64 字符、小写字母数字连字符、不以连字符开头/结尾
      4. name 与目录名一致
      5. description 非空且 <= 1024 字符
      6. description 第一句含触发词(use / when / load this / use this)
      7. description 未把其他字段(如 license:)粘连进正文
      8. references/ 与 scripts/ 中引用的文件确实存在
      9. 每个技能正文不超过 500 行

    用法: .\scripts\validate-skills.ps1 [技能根目录]
    默认校验仓库里的 .agents\skills 和 agent\skills 两处。
#>
[CmdletBinding()]
param(
    [string[]]$Roots = @()
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

$repoRoot = Split-Path -Parent $PSScriptRoot
if ($Roots.Count -eq 0) {
    $Roots = @(
        (Join-Path $repoRoot '.agents\skills'),
        (Join-Path $repoRoot 'agent\skills')
    )
}

$fail = 0
$total = 0

foreach ($root in $Roots) {
    if (-not (Test-Path $root)) { continue }
    Write-Host "=== $root ==="

    foreach ($dir in Get-ChildItem $root -Directory) {
        $total++
        $skillFile = Join-Path $dir.FullName 'SKILL.md'
        $errs = @()

        if (-not (Test-Path $skillFile)) {
            Write-Host ("  FAIL {0}: no SKILL.md" -f $dir.Name) -ForegroundColor Red
            $fail++
            continue
        }

        $text = Get-Content $skillFile -Raw -Encoding UTF8
        if ($text -notmatch '(?s)^---\r?\n(.*?)\r?\n---\r?\n') {
            Write-Host ("  FAIL {0}: frontmatter missing" -f $dir.Name) -ForegroundColor Red
            $fail++
            continue
        }
        $fm = $Matches[1]

        # --- parse YAML ---
        $name = $null; $desc = $null; $license = $null
        $lines = $fm -split "`r?`n"
        $mode = $null
        $descBuf = @()
        foreach ($ln in $lines) {
            if ($ln -match '^name:\s*(.+)$') { $name = $Matches[1].Trim().Trim('"').Trim("'"); continue }
            if ($ln -match '^license:\s*(.+)$') { $license = $Matches[1].Trim(); continue }
            if ($ln -match '^description:\s*\|\s*$') { $mode = 'desc'; continue }
            if ($ln -match '^description:\s*(.+)$') { $desc = $Matches[1].Trim().Trim('"').Trim("'"); $mode = $null; continue }
            if ($mode -eq 'desc') {
                if ($ln -match '^\s{2,}\S') { $descBuf += $ln.Trim() }
                else { $mode = $null }
            }
        }
        if (-not $desc -and $descBuf.Count) { $desc = ($descBuf -join ' ') }

        # --- checks ---
        if (-not $name) { $errs += 'name missing' }
        else {
            if ($name -ne $dir.Name) { $errs += "name '$name' != dir '$($dir.Name)'" }
            if ($name.Length -gt 64) { $errs += 'name too long' }
            if ($name -notmatch '^[a-z0-9]+(-[a-z0-9]+)*$') { $errs += 'name not kebab-case' }
        }
        if (-not $desc) { $errs += 'description missing' }
        else {
            if ($desc.Length -gt 1024) { $errs += "description too long ($($desc.Length))" }
            $first = ($desc -split '\.')[0].ToLower()
            if ($first -notmatch '\b(use|when|load this|use this)\b') { $errs += 'description first sentence lacks a trigger phrase' }
            foreach ($leak in @('license:', 'compatibility:', 'metadata:', 'allowed-tools:')) {
                if ($desc -match [regex]::Escape($leak)) { $errs += "description swallows '$leak'" }
            }
        }

        # --- referenced files exist ---
        $body = $text.Substring($text.IndexOf("---`n", 3))
        foreach ($m in [regex]::Matches($body, '`(references|scripts)/([A-Za-z0-9_\-\.\u4e00-\u9fff]+)`')) {
            $rel = $m.Groups[1].Value + '\' + $m.Groups[2].Value
            if (-not (Test-Path (Join-Path $dir.FullName $rel))) {
                $errs += "referenced file missing: $rel"
            }
        }

        $lineCount = ($text -split "`r?`n").Count
        if ($lineCount -gt 500) { $errs += "body too long ($lineCount lines)" }

        if ($errs.Count) {
            $fail++
            Write-Host ("  FAIL {0}" -f $dir.Name) -ForegroundColor Red
            foreach ($e in $errs) { Write-Host ("        - {0}" -f $e) -ForegroundColor Red }
        } else {
            Write-Host ("  ok   {0,-22} desc={1,4}ch  lines={2}" -f $dir.Name, $desc.Length, $lineCount) -ForegroundColor Green
        }
    }
    Write-Host ''
}

Write-Host ("checked {0} skills, {1} failure(s)" -f $total, $fail) -ForegroundColor $(if ($fail) { 'Red' } else { 'Green' })
exit $(if ($fail) { 1 } else { 0 })
