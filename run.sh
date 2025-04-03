API_URL="http://localhost:8081/resolve/singer-config"
OUTPUT_FILE="tap_config.json"

# Load environment variables from the .env file
ADAPTER_CREDENTIALS=$(grep '^ADAPTER_CREDENTIALS=' .env | cut -d '=' -f2-)

# Ensure ADAPTER_CREDENTIALS is loaded from the .env file
if [ -z "$ADAPTER_CREDENTIALS" ]; then
echo "Error: ADAPTER_CREDENTIALS is not set in the .env file"
exit 1
fi

# Prepare the payload with ADAPTER_CREDENTIALS
PAYLOAD=$(echo "$ADAPTER_CREDENTIALS" | jq '.')

echo "Payload being sent to API: $PAYLOAD"

# Make the API POST request and get the JSON response
RESPONSE=$(curl -s -w "%{http_code}" -o response.json -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$API_URL")

# Capture the HTTP status code
HTTP_STATUS=$(tail -n 1 <<< "$RESPONSE")

# Check if the HTTP status code is 2xx (success)
if [[ "$HTTP_STATUS" -ge 200 && "$HTTP_STATUS" -lt 300 ]]; then
# Ensure the response is valid JSON
if jq empty response.json 2>/dev/null; then
    # Write the valid JSON response to the specified file
    mv response.json "$OUTPUT_FILE"
    echo "Successfully wrote data to $OUTPUT_FILE"
else
    echo "Error: API response is not valid JSON"
    exit 1
fi
else
echo "Error calling API: $API_URL"
echo "HTTP Status Code: $HTTP_STATUS"
echo "Response: $(cat response.json)"
exit 1
fi