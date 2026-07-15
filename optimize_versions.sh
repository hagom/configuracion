#!/bin/bash
# Optimized Versions con HDR passthrough - Jellyfin Raspberry Pi
# Uso: ./optimize_versions.sh /ruta/al/video.mkv

INPUT="$1"
DIR=$(dirname "$INPUT")
BASE=$(basename "$INPUT")
NAME="${BASE%.*}"
EXT="${BASE##*.}"

OUTPUT="$DIR/${NAME}.optimized.${EXT}"

if [ -f "$OUTPUT" ]; then
    echo "Ya existe: $OUTPUT"
    exit 1
fi

echo "Input:  $INPUT"
echo "Output: $OUTPUT"
echo

/usr/lib/jellyfin-ffmpeg/ffmpeg -y \
    -hwaccel v4l2m2m \
    -i "$INPUT" \
    -c:v copy \
    -c:a flac \
    -compression_level 0 \
    -c:s copy \
    -map 0 \
    "$OUTPUT"

echo
echo "OK: $OUTPUT"
