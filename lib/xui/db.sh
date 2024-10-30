#!/bin/bash

db_object_key="data/x-ui.db"
db_local_file="$s3_dir/x-ui.db"
wait_time=60 # seconds
object_creation_time_delta=$((10 * 60)) # seconds

# Function to get the latest version information
get_latest_version_info() {
    aws s3api list-object-versions --bucket "$s3_bucket_name" --prefix "$db_object_key" \
        --query 'Versions | sort_by(@, &LastModified)[-1]' --output json
}

# Function to check if the latest version is recent
is_version_recent() {
    local last_modified=$1
    # Convert last modified time to epoch seconds
    last_modified_epoch=$(date -d "$last_modified" +%s)
    # Get the current time in epoch seconds
    current_time_epoch=$(date +%s)
    # Calculate the time difference
    time_diff=$((current_time_epoch - last_modified_epoch))
    # Check if the difference is within the time threshold
    [[ $time_diff -le $object_creation_time_delta ]]
}

download_this_version() {
    local version_id=$1
    aws s3api get-object --bucket "$s3_bucket_name" --key "$db_object_key" \
        --version-id "$version_id" "$db_local_file"
    echo "Downloaded the latest available version to $db_local_file"
    exit 0
}

# Attempt 1: Initial check
version_info=$(get_latest_version_info)
if [[ $? -ne 0 || -z "$version_info" ]]; then
    echo "Failed to retrieve version info or no versions found."
    exit 1
fi

# Extract version ID and last modified time
latest_version_id=$(echo "$version_info" | jq -r '.VersionId')
last_modified=$(echo "$version_info" | jq -r '.LastModified')

echo "Attempt 1 - Latest version ID: $latest_version_id, Last modified: $last_modified"
if is_version_recent "$last_modified"; then download_this_version "$latest_version_id"; fi

# Wait 1 minute
echo "The latest version is older than $((object_creation_time_delta / 60)) minutes. Waiting for $wait_time seconds ..."
sleep $wait_time

# Attempt 2: Second check
version_info=$(get_latest_version_info)
latest_version_id=$(echo "$version_info" | jq -r '.VersionId')
last_modified=$(echo "$version_info" | jq -r '.LastModified')

echo "Attempt 2 - Latest version ID: $latest_version_id, Last modified: $last_modified"
if is_version_recent "$last_modified"; then download_this_version "$latest_version_id"; fi

# Wait 1 minute again
echo "The latest version is still older than 10 minutes. Waiting for $wait_time more seconds..."
sleep $wait_time

# Attempt 3: Final check
version_info=$(get_latest_version_info)
latest_version_id=$(echo "$version_info" | jq -r '.VersionId')
last_modified=$(echo "$version_info" | jq -r '.LastModified')

echo "Attempt 3 - Latest version ID: $latest_version_id, Last modified: $last_modified"

if is_version_recent "$last_modified"; then
    echo "The latest version was created within the last $((object_creation_time_delta / 60)) minutes."
else
    echo "No recent version found. Downloading the last available version."
fi

download_this_version "$latest_version_id"
