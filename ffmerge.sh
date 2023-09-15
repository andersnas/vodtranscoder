#!/bin/bash

# Check if the user provided the required arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <FULL_FILENAME> <WORK_PATH> <OUTPUT_PATH>"
    exit 1
fi

FULL_FILENAME="$1"
WORK_DIRECTORY="$2"
OUTPUT_DIRECTORY="$3"
BASE_FILENAME="${FULL_FILENAME%.*}" # Remove extension

# Navigate to the directory
cd "$WORK_DIRECTORY" || { echo "Failed to change to directory $WORK_DIRECTORY"; exit 1; }

# Create lists for each bitrate
for bitrate in 1080p 720p 480p 360p 240p; do
    rm -f concat_list_${bitrate}.txt
    for seg in $(ls ${BASE_FILENAME}_segment_*_${bitrate}.mp4 | sort -V); do
        echo "file '$seg'" >> concat_list_${bitrate}.txt
    done
done

# Merge segments using ffmpeg for each bitrate
for bitrate in 1080p 720p 480p 360p 240p; do
    ffmpeg -y -f concat -safe 0 -i concat_list_${bitrate}.txt -c copy ${OUTPUT_DIRECTORY}/${FULL_FILENAME}_${bitrate}.mp4
done

# Cleanup
for bitrate in 1080p 720p 480p 360p 240p; do
    rm -f concat_list_${bitrate}.txt
done
