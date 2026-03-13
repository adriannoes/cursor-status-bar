#!/bin/bash
# Usage: ./Scripts/fetch_usage_with_token.sh "WORKOS_TOKEN" [USER_ID]
# Get token from: cursor.com/dashboard → DevTools → Network → usage request → Cookie: WorkosCursorSessionToken
# If USER_ID omitted, extracted from token (part before %3A%3A) or use "me"

TOKEN="$1"
USER_ID="${2:-}"

if [ -z "$TOKEN" ]; then
  echo "Usage: $0 WORKOS_TOKEN [USER_ID]"
  echo ""
  echo "Get token: cursor.com/dashboard → DevTools → Network → find 'usage' request →"
  echo "  Copy value of WorkosCursorSessionToken from Request Headers"
  exit 1
fi

if [ -z "$USER_ID" ]; then
  if [[ "$TOKEN" == *"%3A%3A"* ]]; then
    USER_ID="${TOKEN%%%3A%3A*}"
  else
    USER_ID="me"
  fi
fi

echo "Fetching usage for user: $USER_ID"
echo ""

curl -s -H "Content-Type: application/json" \
  -H "Cookie: WorkosCursorSessionToken=$TOKEN" \
  -H "Origin: https://cursor.com" \
  -H "Referer: https://cursor.com/dashboard" \
  "https://cursor.com/api/usage?user=$USER_ID" | python3 -m json.tool
