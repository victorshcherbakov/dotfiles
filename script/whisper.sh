#!/bin/bash

# whisper.cpp speech-to-text for nvim voice notes (sinbizkit/voice_note.lua).
# Built from the latest release tag: distro packages lag behind or do not exist.

src_dir="$HOME/.local/src/whisper.cpp"
model_dir="$HOME/.local/share/whisper"
model=large-v3-turbo-q5_0
# Voice activity detection: without it whisper hallucinates text on silence.
vad_model=silero-v6.2.0

tag=$(git ls-remote --tags --refs https://github.com/ggml-org/whisper.cpp \
	| awk -F/ '{print $3}' | sort -V | tail -1)
[[ -n "$tag" ]] || { echo "whisper.cpp: failed to resolve the latest tag" >&2; exit 1; }

if [[ -d "$src_dir/.git" ]]; then
	git -C "$src_dir" fetch --depth 1 origin tag "$tag" || exit 1
	git -C "$src_dir" checkout --force "$tag" || exit 1
else
	git clone --depth 1 --branch "$tag" https://github.com/ggml-org/whisper.cpp "$src_dir" || exit 1
fi

# Static libs, so the single copied binary does not need libwhisper.so next to it.
cmake -S "$src_dir" -B "$src_dir/build" -DCMAKE_BUILD_TYPE=Release \
	-DBUILD_SHARED_LIBS=OFF -DWHISPER_BUILD_TESTS=OFF || exit 1
cmake --build "$src_dir/build" --target whisper-cli -j "$(nproc)" || exit 1
install -D "$src_dir/build/bin/whisper-cli" "$HOME/.local/bin/whisper-cli" || exit 1

mkdir -p "$model_dir"
if [[ ! -f "$model_dir/ggml-$model.bin" ]]; then
	bash "$src_dir/models/download-ggml-model.sh" "$model" "$model_dir" || exit 1
fi
if [[ ! -f "$model_dir/ggml-$vad_model.bin" ]]; then
	bash "$src_dir/models/download-vad-model.sh" "$vad_model" "$model_dir" || exit 1
fi
