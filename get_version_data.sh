#!/bin/bash

# Configuration
API_URL="https://api.modrinth.com/v2/search"
OUTPUT_FILE="versions.csv"
SLEEP_DELAY=1 # Delay in seconds between requests to avoid rate limits

# List of Minecraft versions to check
VERSIONS=(
    "1.21.10"
    "1.21.9"
    "1.21.8"
    "1.21.7"
    "1.21.6"
    "1.21.5"
    "1.21.4"
    "1.21.3"
    "1.21.2"
    "1.21.1"
    "1.21"
    "1.20.6"
    "1.20.5"
    "1.20.4"
    "1.20.3"
    "1.20.2"
    "1.20.1"
    "1.20"
    "1.19.4"
    "1.19.3"
    "1.19.2"
    "1.19.1"
    "1.19"
    "1.18.2"
    "1.18.1"
    "1.18"
    "1.17.1"
    "1.17"
    "1.16.5"
    "1.16.4"
    "1.16.3"
    "1.16.2"
    "1.16.1"
    "1.16"
    "1.15.2"
    "1.15.1"
    "1.15"
    "1.14.4"
    "1.14.3"
    "1.14.2"
    "1.14.1"
    "1.14"
    "1.13.2"
    "1.13.1"
    "1.13"
    "1.12.2"
    "1.12.1"
    "1.12"
    "1.11.2"
    "1.11.1"
    "1.11"
    "1.10.2"
    "1.10.1"
    "1.10"
    "1.9.4"
    "1.9.3"
    "1.9.2"
    "1.9.1"
    "1.9"
    "1.8.9"
    "1.8.8"
    "1.8.7"
    "1.8.6"
    "1.8.5"
    "1.8.4"
    "1.8.3"
    "1.8.2"
    "1.8.1"
    "1.8"
    "1.7.10"
    "1.7.9"
    "1.7.8"
    "1.7.7"
    "1.7.6"
    "1.7.5"
    "1.7.4"
    "1.7.3"
    "1.7.2"
    "1.6.4"
    "1.6.2"
    "1.6.1"
    "1.5.2"
    "1.5.1"
    "1.4.7"
    "1.4.6"
    "1.4.5"
    "1.4.4"
    "1.4.2"
    "1.3.2"
    "1.3.1"
    "1.2.5"
    "1.2.4"
    "1.2.3"
    "1.2.2"
    "1.2.1"
    "1.1"
    "1.0"
)

# 1. Create the CSV file and write the header
echo "mc_vers,total_hits" > "$OUTPUT_FILE"
echo "Starting data collection..."

# 2. Loop through each version
for version in "${VERSIONS[@]}"; do
    echo "Processing version: $version"

    # 3. Construct the URL-encoded facets string for the current version
    # The string is: [["versions:<version>"]]
    # We use printf and urlencode for safety, but for this specific structure, 
    # we can substitute the un-encoded version into the fully-encoded template.
    
    # Template: %5B%5B%22versions%3A<version>%22%5D%5D
    FACET_STRING=%5B%5B%22versions%3A$version%22%5D%5D
    
    # 4. Execute the cURL request and pipe the JSON response to jq
    # We use limit=1 as we only need the total_hits field.
    HITS=$(curl -s "$API_URL?facets=$FACET_STRING&limit=1" | jq '.total_hits')

    # 5. Check if jq returned a valid number
    if [[ "$HITS" =~ ^[0-9]+$ ]]; then
        # 6. Append the version and total_hits to the CSV file
        echo "$version,$HITS" >> "$OUTPUT_FILE"
        echo "  -> Found $HITS projects."
    else
        echo "  -> Error retrieving data for $version. Output was: $HITS"
        echo "$version,ERROR" >> "$OUTPUT_FILE"
    fi

    # 7. Pause to respect API rate limits
    sleep "$SLEEP_DELAY"

done

echo "---"
echo "Finished! Data saved to $OUTPUT_FILE"