#!/bin/bash

FALLBACK_VERSION="0.15.0"

if ! command -v dotnet &>/dev/null; then
	echo "'dotnet' is required. Install .NET SDK first."
	exit 1
fi

dotnet tool install --global csharp-ls ||
	dotnet tool update --global csharp-ls ||
	dotnet tool install --global csharp-ls --version ${FALLBACK_VERSION}

if command -v csharp-ls &>/dev/null; then
	echo "csharp-ls installed successfully: $(csharp-ls --version)"
	exit 0
fi

echo "csharp-ls not found in PATH. Make sure ~/.dotnet/tools is in your PATH."
exit 1
