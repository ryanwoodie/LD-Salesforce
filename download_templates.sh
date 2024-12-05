#!/bin/bash

# Script to download Salesforce Email Templates using the sf CLI
# Ensure the sf CLI is installed and authenticated

# Input CSV file
CSV_FILE="email_templates.csv"

# Function to download an email template
download_template() {
    local developer_name=$1
    local folder_name=$2
    local output_dir="email_templates/${folder_name}"

    # Create the output directory if it doesn't exist
    mkdir -p "$output_dir"

    # Execute the sf command to retrieve the email template
    echo "Retrieving Email Template: $developer_name in Folder: $folder_name"
    sf project retrieve start -m "EmailTemplate:${developer_name}" --target-metadata-dir "$output_dir" > /dev/null 2>&1

    # Check if the retrieval was successful
    if [ $? -eq 0 ]; then
        echo "Retrieved successfully: $developer_name"
    else
        echo "Failed to retrieve: $developer_name"
    fi
}

# Read the CSV file and download templates
while IFS=, read -r developer_name folder_name; do
    # Skip the header row
    if [[ $developer_name == "DeveloperName" ]]; then
        continue
    fi

    download_template "$developer_name" "$folder_name"
done < "$CSV_FILE"

echo "All email templates processed."