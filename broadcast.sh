
CSV_FILE=process.env.CSV_FILE
API_TOKEN=process.env.API_TOKEN
API_URL=process.env.API_URL
YOUR_ID=process.env.YOUR_ID

if [ ! -f "$CSV_FILE" ]; then
  echo "Error: $CSV_FILE not found"
  exit 1
fi

# Create a temp file for updates
TMP_FILE=$(mktemp)

# Read CSV line by line
while IFS='|' read -r email subject body category status
do
  # Skip empty lines
  [ -z "$email" ] && continue

  # If already sent, just copy the row and continue
  if [ "$status" = "sent" ]; then
    echo "$email|$subject|$body|$category|sent" >> "$TMP_FILE"
    continue
  fi

  echo "Sending email to: $email"

  # Send via curl and capture HTTP status
  if curl --location --request POST \
   'https://sandbox.api.mailtrap.io/api/send/'"$YOUR_ID"'' \
    --header 'Authorization: Bearer '"$API_TOKEN"'' \
    --header 'Content-Type: application/json' \
    --data '{ "from": {"email":"noreply@example.com"}, 
      "to": [{"email":"'"$email"'"}], 
      "subject": "'"$subject"'", 
      "text": "'"$body"'" }' > /dev/null; then
      echo "Email sent successfully: $email"
      echo "$email|$subject|$body|$category|sent" >> "$TMP_FILE"
  else
    echo "Failed to send email ($response): $email"
    echo "$email|$subject|$body|$category|pending" >> "$TMP_FILE"
  fi
  
  sleep 10
  echo ""

done < "$CSV_FILE"

# Replace the old CSV with updated one
mv "$TMP_FILE" "$CSV_FILE"
