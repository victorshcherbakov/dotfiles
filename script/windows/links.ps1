#Requires -Version 5.1
<#
.SYNOPSIS
Symlink helpers shared by the Windows install scripts.

.DESCRIPTION
Symbolic links (not junctions) are used throughout, so files and directories are
handled the same way and a broken link is visible as such. They require Developer
Mode - Settings > Update & Security > For developers - which lets an ordinary
user create them.

Links are made with mklink rather than New-Item -ItemType SymbolicLink:
PowerShell 5.1 does not pass the unprivileged-create flag and still demands
elevation even when Developer Mode is on.

Nothing real is ever deleted. A destination holding a genuine file or directory
stops the caller; -Force only moves it aside under a timestamped name. Removing
an existing *link* goes through the .NET delete calls, because Remove-Item
-Recurse on a directory symlink in PowerShell 5.1 can empty the target instead
of dropping the link.
#>

Set-StrictMode -Version Latest

function Test-Link {
	param([Parameter(Mandatory)][string]$Path)

	if (-not (Test-Path -LiteralPath $Path)) { return $false }
	$item = Get-Item -LiteralPath $Path -Force
	return [bool]($item.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

function Get-LinkTarget {
	param([Parameter(Mandatory)][string]$Path)

	$item = Get-Item -LiteralPath $Path -Force
	$target = $item.Target
	if ($target -is [array]) { $target = $target[0] }
	return $target
}

function Remove-Link {
	param([Parameter(Mandatory)][string]$Path)

	$item = Get-Item -LiteralPath $Path -Force
	if ($item.PSIsContainer) {
		[System.IO.Directory]::Delete($item.FullName)
	} else {
		[System.IO.File]::Delete($item.FullName)
	}
}

function New-Link {
	<#
	.SYNOPSIS
	Point $Path at $Target, reporting what it did. Returns $true on success.

	.PARAMETER Quiet
	Report only actual changes, so an unchanged tree produces no output.
	#>
	param(
		[Parameter(Mandatory)][string]$Path,
		[Parameter(Mandatory)][string]$Target,
		[switch]$Force,
		[switch]$Check,
		[switch]$Quiet,
		[string]$Prefix = 'link'
	)

	if (-not (Test-Path -LiteralPath $Target)) {
		Write-Error "${Prefix}: missing source $Target"
		return $false
	}

	if (Test-Link -Path $Path) {
		if ((Get-LinkTarget -Path $Path) -eq $Target) {
			if (-not $Quiet) { Write-Host "${Prefix}: ok $Path" }
			return $true
		}
		if ($Check) {
			Write-Host "${Prefix}: would relink $Path -> $Target"
			return $true
		}
		Remove-Link -Path $Path
	} elseif (Test-Path -LiteralPath $Path) {
		if (-not $Force) {
			Write-Error "${Prefix}: $Path is a real file/directory - move it aside first, or pass -Force"
			return $false
		}
		$backup = "$Path.bak-$(Get-Date -Format 'yyyyMMddHHmmss')"
		if ($Check) {
			Write-Host "${Prefix}: would move $Path to $backup"
			return $true
		}
		Move-Item -LiteralPath $Path -Destination $backup
		Write-Host "${Prefix}: moved $Path to $backup"
	} elseif ($Check) {
		Write-Host "${Prefix}: would link $Path -> $Target"
		return $true
	}

	$parent = Split-Path -Parent $Path
	if (-not (Test-Path -LiteralPath $parent)) {
		New-Item -ItemType Directory -Path $parent -Force | Out-Null
	}

	$switch = ''
	if ((Get-Item -LiteralPath $Target -Force).PSIsContainer) { $switch = '/D ' }
	cmd /c "mklink $switch`"$Path`" `"$Target`"" | Out-Null
	if ($LASTEXITCODE -ne 0) {
		Write-Error "${Prefix}: mklink failed for $Path - is Developer Mode on? (Settings > Update & Security > For developers)"
		return $false
	}

	Write-Host "${Prefix}: $Path -> $Target"
	return $true
}
