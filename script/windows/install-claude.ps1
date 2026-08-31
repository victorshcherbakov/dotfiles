#Requires -Version 5.1
<#
.SYNOPSIS
Link the dotfiles claude/ package into $HOME\.claude - the Windows stand-in for
`make install-claude`.

.DESCRIPTION
GNU Stow is a Unix tool, so on Windows the same layout is reproduced with
symbolic links (see links.ps1 for how and why). Top-level files and the
commands/ and hooks/ directories are linked whole; skills/ stays a real
directory holding one link per skill, so install-private.ps1 can drop private
skills next to them without those landing inside this public repo.

Prerequisites: Developer Mode (for unprivileged symlinks), Git for Windows (its
Git Bash runs the hooks) and Python 3 reachable through the `py` launcher.

.PARAMETER Force
Move a conflicting real file or directory to <name>.bak-<timestamp> instead of
stopping. Nothing is ever deleted.

.PARAMETER Check
Report what would change and exit without touching anything.

.EXAMPLE
powershell -ExecutionPolicy Bypass -File script\windows\install-claude.ps1 -Check
#>
[CmdletBinding()]
param(
	[switch]$Force,
	[switch]$Check
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'links.ps1')

$repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$source = Join-Path $repo 'claude\.claude'
$dest = Join-Path $env:USERPROFILE '.claude'

if (-not (Test-Path -LiteralPath $source)) {
	Write-Error "claude: package not found at $source"
	exit 1
}

if (-not (Test-Path -LiteralPath $dest)) {
	New-Item -ItemType Directory -Path $dest -Force | Out-Null
}

# Everything at the top level of the package except skills/, which is unfolded
# one level below so private skills can live alongside the repo ones.
$entries = @('CLAUDE.md', 'AGENTS.md', 'settings.json', 'commands', 'hooks')

$failed = 0
foreach ($entry in $entries) {
	$ok = New-Link -Path (Join-Path $dest $entry) -Target (Join-Path $source $entry) `
		-Force:$Force -Check:$Check -Prefix 'claude' -ErrorAction Continue
	if (-not $ok) { $failed++ }
}

$skills = Join-Path $dest 'skills'
if ((Test-Path -LiteralPath $skills) -and (Test-Link -Path $skills)) {
	# A whole-directory link left by an earlier layout would send every private
	# skill straight into the public repo.
	if ($Check) {
		Write-Host "claude: would unfold $skills into a real directory"
	} else {
		Remove-Link -Path $skills
	}
}
if (-not $Check -and -not (Test-Path -LiteralPath $skills)) {
	New-Item -ItemType Directory -Path $skills -Force | Out-Null
}

foreach ($skill in Get-ChildItem -LiteralPath (Join-Path $source 'skills') -Directory) {
	$ok = New-Link -Path (Join-Path $skills $skill.Name) -Target $skill.FullName `
		-Force:$Force -Check:$Check -Prefix 'claude' -ErrorAction Continue
	if (-not $ok) { $failed++ }
}

if ($failed -gt 0) {
	Write-Error "claude: $failed link(s) failed"
	exit 1
}

Write-Host 'claude: done'
