#!/bin/bash

# Check that the user provided the required arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <STORAGE_PATH> <TARGET_FILE>"
    exit 1
fi

STORAGE_PATH="$1"
TARGET_FILE="$2"

process_file() {
    local trigger_file_path="$1"
    # Read the command from the trigger file
    local command_to_run=$(cat "$trigger_file_path")
    # Execute the command
    bash -c "$command_to_run"
    echo "Executed command: $command_to_run"
}

echo "Script looking for file ${STORAGE_PATH}/${TARGET_FILE}"

while true; do
    echo "Checking for the file at ${STORAGE_PATH}/${TARGET_FILE}"  # Debug statement
    if [ -f "${STORAGE_PATH}/${TARGET_FILE}" ]; then
        echo "$TARGET_FILE has been detected!"
        process_file "${STORAGE_PATH}/${TARGET_FILE}"
        exit 0
    else
        echo "$TARGET_FILE not found."  # Debug statement
    fi
    sleep 5  # Wait for 5 seconds before checking again
done
