#!/bin/bash

db_object_key="data/xui/x-ui.db"
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

# Function to download the latest version
download_this_version() {
    local version_id=$1
    aws s3api get-object --bucket "$s3_bucket_name" --key "$db_object_key" \
        --version-id "$version_id" "$db_local_file"
    echo "Downloaded the version with ID $version_id to $db_local_file"
}

# Attempt to find a recent version up to 3 times
for attempt in {1..3}; do
    # Fetch the latest version info
    version_info=$(get_latest_version_info)
    if [[ $? -ne 0 || -z "$version_info" ]]; then
        echo "Failed to retrieve version info or no versions found."
        break
    fi

    # Extract version ID and last modified time
    latest_version_id=$(echo "$version_info" | jq -r '.VersionId')
    last_modified=$(echo "$version_info" | jq -r '.LastModified')

    echo "Attempt $attempt: Latest version ID: $latest_version_id, Last modified: $last_modified"

    # Check if the latest version was created in the last 10 minutes
    if is_version_recent "$last_modified"; then
        echo "The latest version was created within the last $((object_creation_time_delta / 60)) minutes."
        download_this_version "$latest_version_id"
        break
    else
        echo "The latest version is older than $((object_creation_time_delta / 60)) minutes."
        # On the third attempt, download the latest version anyway
        if [[ $attempt -eq 3 ]]; then
            echo "No recent version found after 3 attempts. Downloading the last available version."
            download_this_version "$latest_version_id"
        else
            echo "Waiting for $wait_time more seconds before retrying..."
            sleep $wait_time
        fi
    fi
done

echo "Database download completed."
