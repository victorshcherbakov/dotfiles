#Requires -Version 5.1
<#
.SYNOPSIS
Link the private, machine-local files from Yandex.Disk into place on Windows -
the counterpart of `make install-private`.

.DESCRIPTION
Mirrors script/private_links.sh entry for entry. The files live on Yandex.Disk
(synced between machines) instead of this public repo; the Windows client syncs
into %USERPROFILE%\YandexDisk, without the dot the Linux client uses.

Fails loudly when anything is missing rather than linking half of it: an absent
blocklist leaves the pre-commit privacy scan without the machine-specific
patterns, and an absent import silently drops global rules from the session.

Override the source directory with -PrivateDir or $env:PRIVATE_DOTFILES_DIR.

.PARAMETER Force
Move a conflicting real file or directory to <name>.bak-<timestamp> instead of
stopping. Nothing is ever deleted.

.PARAMETER Check
Report what would change and exit without touching anything.
#>
[CmdletBinding()]
param(
	[string]$PrivateDir,
	[switch]$Force,
	[switch]$Check
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'links.ps1')

if (-not $PrivateDir) {
	$PrivateDir = $env:PRIVATE_DOTFILES_DIR
}
if (-not $PrivateDir) {
	$PrivateDir = Join-Path $env:USERPROFILE 'YandexDisk\private\dotfiles'
}

if (-not (Test-Path -LiteralPath $PrivateDir)) {
	Write-Error "private: directory not found: $PrivateDir"
	Write-Error 'private: is Yandex.Disk synced yet? -PrivateDir overrides the path'
	exit 1
}

$repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$gitDir = & git -C $repo rev-parse --absolute-git-dir 2>$null
if ($LASTEXITCODE -ne 0 -or -not $gitDir) {
	Write-Error "private: $repo is not a git repository"
	exit 1
}

$claude = Join-Path $env:USERPROFILE '.claude'

# Source under $PrivateDir -> absolute destination. A $null destination means the
# file is read from Yandex.Disk directly and only has to exist.
$entries = [ordered]@{
	'secret-patterns'        = Join-Path $gitDir 'secret-patterns'
	'claude-private.md'      = Join-Path $claude 'private.md'
	'skills\customer-reply'  = Join-Path $claude 'skills\customer-reply'
	'ssh_config_private'     = $null
}

$failed = 0
foreach ($entry in $entries.GetEnumerator()) {
	$src = Join-Path $PrivateDir $entry.Key
	if (-not (Test-Path -LiteralPath $src)) {
		Write-Error "private: missing source $src"
		$failed++
		continue
	}
	if (-not $entry.Value) { continue }

	$ok = New-Link -Path $entry.Value -Target $src `
		-Force:$Force -Check:$Check -Prefix 'private' -ErrorAction Continue
	if (-not $ok) { $failed++ }
}

if ($failed -gt 0) {
	Write-Error "private: $failed entry(ies) failed"
	exit 1
}

Write-Host 'private: done'
