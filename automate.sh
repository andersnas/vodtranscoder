#!/bin/bash

# Define constants
source config.cfg
ROOT_PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 22)
random=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)
LOG_FILE="$OUTPUT_FOLDER/$random.log"

log_message() {
    local MESSAGE="$1"
    echo "$(date +"%Y-%m-%d %H:%M:%S") : $MESSAGE" >> "$LOG_FILE"
}

log_message "Random ID: $random"

# Validate input arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <PATH/FILENAME> <NUMBER_OF_MACHINES>"
    exit 1
fi

FILEPATH="$1"
NUMBER_OF_MACHINES="$2"
DIRNAME=$(dirname "$FILEPATH")

BASENAME=$(basename "$FILEPATH") # Extracts the base name with extension
FILENAME_NOEXT="${BASENAME%.*}"  # Extracts the file name without extension

log_message "FILEPATH: ${FILEPATH}"
log_message "DIRNAME: ${DIRNAME}"
log_message "BASENAME: ${BASENAME}"
log_message "FILENAME_NOEXT: ${FILENAME_NOEXT}"

log_message "Creating working directory: ${DIRNAME}/$random"
mkdir ${DIRNAME}/$random

log_message "Splitting file"
./ffsplit.sh "$FILEPATH" "${DIRNAME}/$random" "$NUMBER_OF_MACHINES"

log_message "Deploying transcoders"
terraform init
terraform plan -var="logfile=$LOG_FILE" -var="rootpassword=$ROOT_PASSWORD" -var="storagebaseurl=$STORAGE_BASE_URL" -var="objectkeys=$OBJECT_KEYS" -var="random=$random" -var="videofile=${FILENAME_NOEXT}_segment" -var="machinetype=$MACHINE_TYPE" -var="machinecount=$NUMBER_OF_MACHINES" -var="region=$REGION" -var="public_key=$PUBLIC_KEY"
terraform apply -var="logfile=$LOG_FILE" -var="rootpassword=$ROOT_PASSWORD" -var="storagebaseurl=$STORAGE_BASE_URL" -var="objectkeys=$OBJECT_KEYS" -var="random=$random" -var="videofile=${FILENAME_NOEXT}_segment" -var="machinetype=$MACHINE_TYPE" -var="machinecount=$NUMBER_OF_MACHINES" -var="region=$REGION" -var="public_key=$PUBLIC_KEY" -auto-approve

log_message "Merge segments"
./ffmerge.sh "$BASENAME" "${DIRNAME}/$random" "$OUTPUT_FOLDER"

log_message "Write confirmation file"
echo  "$OUTPUT_FOLDER/$random.log" > "$OUTPUT_FOLDER/$BASENAME.txt"


log_message "Remove work folder"
rm "${DIRNAME}/$random/"*
rmdir "${DIRNAME}/$random"

log_message "Decomissioning transcoders"
terraform plan -destroy -var="logfile=$LOG_FILE" -var="rootpassword=$ROOT_PASSWORD" -var="storagebaseurl=$STORAGE_BASE_URL" -var="objectkeys=$OBJECT_KEYS" -var="random=$random" -var="videofile=${FILENAME_NOEXT}_segment" -var="machinetype=$MACHINE_TYPE" -var="machinecount=$NUMBER_OF_MACHINES" -var="region=$REGION" -var="public_key=$PUBLIC_KEY"
terraform destroy -var="logfile=$LOG_FILE" -var="rootpassword=$ROOT_PASSWORD" -var="storagebaseurl=$STORAGE_BASE_URL" -var="objectkeys=$OBJECT_KEYS" -var="random=$random" -var="videofile=${FILENAME_NOEXT}_segment" -var="machinetype=$MACHINE_TYPE" -var="machinecount=$NUMBER_OF_MACHINES" -var="region=$REGION" -var="public_key=$PUBLIC_KEY" -auto-approve

log_message "Done"
