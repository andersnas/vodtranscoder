#!/bin/bash

# Check if the arguments are provided correctly
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "Usage: $0 <VIDEO_FILE_FULL_PATH> <OUTPUT_DIRECTORY> [NUMBER_OF_SEGMENTS]"
    exit 1
fi

VIDEO_FILE="$1"
OUTPUT_DIR="$2"
SEGMENT_COUNT="${3:-10}" # default to 10 if not provided

# Check if the video file exists
if [ ! -f "$VIDEO_FILE" ]; then
    echo "Error: File $VIDEO_FILE does not exist."
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Get the duration of the video in seconds
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VIDEO_FILE")
SEGMENT_TIME=$(echo "scale=2; $DURATION / $SEGMENT_COUNT" | bc)

# Directory and filename extraction from the full path
DIR_PATH=$(dirname "$VIDEO_FILE")
FILENAME=$(basename "$VIDEO_FILE")

# Split the video
OUTPUT_PREFIX="${FILENAME%.*}_segment"
ffmpeg -i "$VIDEO_FILE" -c copy -f segment -segment_time "$SEGMENT_TIME" -segment_start_number 1 -reset_timestamps 1 "$OUTPUT_DIR/${OUTPUT_PREFIX}_%d.${FILENAME##*.}"

# For each segment, write the ffmpeg command to an output text file
for i in $(seq 1 $SEGMENT_COUNT); do
    SEGMENT_NAME="${OUTPUT_PREFIX}_${i}.${FILENAME##*.}"
    BASENAME=$(basename "$SEGMENT_NAME" .${FILENAME##*.})
    OUTPUT_FILE="${BASENAME}.txt"

    cat <<-EOL > "$OUTPUT_DIR/$OUTPUT_FILE"
ffmpeg -y -i $OUTPUT_DIR/$SEGMENT_NAME \
  -vf "scale=w=2*trunc(1920/2):h=2*trunc(1080/2)" -c:v libx264 -preset medium -b:v 8M -c:a aac -b:a 192k $OUTPUT_DIR/${BASENAME}_1080p.mp4 \
  -vf "scale=w=2*trunc(1280/2):h=2*trunc(720/2)"  -c:v libx264 -preset medium -b:v 4M -c:a aac -b:a 192k $OUTPUT_DIR/${BASENAME}_720p.mp4 \
  -vf "scale=w=2*trunc(854/2):h=2*trunc(480/2)"  -c:v libx264 -preset medium -b:v 2M -c:a aac -b:a 128k $OUTPUT_DIR/${BASENAME}_480p.mp4 \
  -vf "scale=w=2*trunc(640/2):h=2*trunc(360/2)"  -c:v libx264 -preset medium -b:v 1M -c:a aac -b:a 128k $OUTPUT_DIR/${BASENAME}_360p.mp4 \
  -vf "scale=w=2*trunc(426/2):h=2*trunc(240/2)"  -c:v libx264 -preset medium -b:v 500k -c:a aac -b:a 64k $OUTPUT_DIR/${BASENAME}_240p.mp4
EOL

done

echo "Video split into $SEGMENT_COUNT segments and commands written!"
