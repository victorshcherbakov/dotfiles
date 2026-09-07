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

.PARAMETER Quiet
Report only actual changes, so the git hook running this after every pull stays
silent unless something moved.

.EXAMPLE
powershell -ExecutionPolicy Bypass -File script\windows\install-claude.ps1 -Check
#>
[CmdletBinding()]
param(
	[switch]$Force,
	[switch]$Check,
	[switch]$Quiet
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
		-Force:$Force -Check:$Check -Quiet:$Quiet -Prefix 'claude' -ErrorAction Continue
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
		-Force:$Force -Check:$Check -Quiet:$Quiet -Prefix 'claude' -ErrorAction Continue
	if (-not $ok) { $failed++ }
}

# The loop above only adds. A skill renamed or dropped in the repo leaves a link
# whose target is gone, and Test-Path on a directory symlink reports the entry
# rather than the target, so nothing else ever notices it.
if ((Test-Path -LiteralPath $skills) -and -not (Test-Link -Path $skills)) {
	# Trailing separator, so a sibling directory whose name merely starts the
	# same way cannot match.
	$sourceSkills = (Join-Path $source 'skills') + [IO.Path]::DirectorySeparatorChar
	foreach ($link in Get-ChildItem -LiteralPath $skills -Force) {
		if (-not (Test-Link -Path $link.FullName)) { continue }
		$target = Get-LinkTarget -Path $link.FullName
		if ($target -and (Test-Path -LiteralPath $target)) { continue }

		# Only links into this repo are ours to drop: a private skill is broken
		# merely because Yandex.Disk has not synced yet, and deleting it would
		# turn a wait into a reinstall.
		if ($target -and $target.StartsWith($sourceSkills, [StringComparison]::OrdinalIgnoreCase)) {
			if ($Check) {
				Write-Host "claude: would remove stale link $($link.FullName)"
			} else {
				Remove-Link -Path $link.FullName
				Write-Host "claude: removed stale link $($link.FullName)"
			}
		} else {
			Write-Warning "claude: $($link.FullName) points at missing $target - left alone, it is not from this repo"
		}
	}
}

if ($failed -gt 0) {
	Write-Error "claude: $failed link(s) failed"
	exit 1
}

if (-not $Quiet) { Write-Host 'claude: done' }
