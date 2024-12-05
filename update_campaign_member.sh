#!/bin/bash

# Ensure using the latest Salesforce CLI
export SF_USE_PROGRESS_BAR=false

# Salesforce Campaign ID
CAMPAIGN_ID="701ON00000LZTxWYAX"

# Maximum number of emails to process
MAX_EMAILS=3800

# Number of members to process in each batch
BATCH_SIZE=100

# Counter for processed emails
processed_count=0

while [ $processed_count -lt $MAX_EMAILS ]; do
    # Query multiple CampaignMembers with Status 'added' that haven't been processed
    RECORDS=$(sf data query \
        --query "SELECT Id FROM CampaignMember WHERE CampaignId = '${CAMPAIGN_ID}' AND Status = 'added' LIMIT $BATCH_SIZE" \
        --json | jq -c '.result.records[]')

    # Check if any records were found
    if [ -z "$RECORDS" ]; then
        echo "No records left to process. Exiting."
        break
    fi

    # Loop through each record and update its status
    echo "$RECORDS" | while IFS= read -r record; do
        RECORD_ID=$(echo "$record" | jq -r '.Id')

        echo "Processing CampaignMember: $RECORD_ID"

        # Update the record's Status to 'Drip Started'
        sf data record update \
            --sobject CampaignMember \
            --record-id $RECORD_ID \
            --values "Status='Drip Started'" || {
            echo "Failed to update CampaignMember: $RECORD_ID" >&2
            exit 1
        }

        echo "Updated CampaignMember: $RECORD_ID"

        # Increment the processed count
        processed_count=$((processed_count + 1))

        # Break the loop if we reach the maximum limit
        if [ $processed_count -ge $MAX_EMAILS ]; then
            break
        fi
    done

    # Optional: Delay for 1 second between batches (comment out if not needed)
    # sleep 1
done

echo "Processed a total of $processed_count emails."