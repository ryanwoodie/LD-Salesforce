#!/bin/bash

# Ensure using the latest Salesforce CLI
export SF_USE_PROGRESS_BAR=false

# Salesforce Campaign ID
CAMPAIGN_ID="701ON00000LZTxWYAX"

# Maximum number of emails to process
MAX_EMAILS=4000

# Counter for processed emails
processed_count=0

while [ $processed_count -lt $MAX_EMAILS ]; do
    # Query one CampaignMember with Status 'added' that hasn't been processed
    RECORD_ID=$(sf data query \
        --query "SELECT Id FROM CampaignMember WHERE CampaignId = '${CAMPAIGN_ID}' AND Status = 'added' LIMIT 1" \
        --json | jq -r '.result.records[0].Id')

    # Check if a record was found
    if [ "$RECORD_ID" != "null" ]; then
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
    else
        echo "No records left to process. Exiting."
        break
    fi

    # Delay for 1 second before processing the next record
    sleep 1
done

echo "Processed a total of $processed_count emails."