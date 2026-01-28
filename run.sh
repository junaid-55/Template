#!/bin/bash

# Configuration
BASE_URL="http://localhost:8081"
EMAIL="tester$(date +%s)@example.com" # Unique email every run
PASSWORD="password123"
COOKIE_FILE="cookies.txt"

echo "🚀 Starting Full System Test..."
echo "--------------------------------"

# 1. Health Check
echo "🔍 Checking Gateway & Auth Health..."
curl -s $BASE_URL/api/health | grep -q "ok" && echo "✅ Gateway is UP" || echo "❌ Gateway is DOWN"

# 2. Sign Up
echo "📝 Signing up as $EMAIL..."
SIGNUP_RES=$(curl -s -X POST "$BASE_URL/api/auth/sign-up/email" \
     -H "Content-Type: application/json" \
     -d "{\"email\": \"$EMAIL\", \"password\": \"$PASSWORD\", \"name\": \"Test User\"}")

if [[ $SIGNUP_RES == *"user"* ]]; then
    echo "✅ Sign-up Successful"
else
    echo "❌ Sign-up Failed: $SIGNUP_RES"
    exit 1
fi

# 3. Sign In (Capture Cookies)
echo "🔑 Signing in to get session..."
curl -s -i -X POST "$BASE_URL/api/auth/sign-in/email" \
     -H "Content-Type: application/json" \
     -d "{\"email\": \"$EMAIL\", \"password\": \"$PASSWORD\"}" \
     -c $COOKIE_FILE > /dev/null
echo "✅ Session stored in $COOKIE_FILE"

# 4. Get JWT Token
echo "🎫 Exchanging session for JWT..."
TOKEN_RES=$(curl -s -b $COOKIE_FILE "$BASE_URL/api/auth/token")
# Extract token using sed (matches the string between "token":" and ")
JWT_TOKEN=$(echo $TOKEN_RES | sed 's/.*"token":"\([^"]*\)".*/\1/')

if [ -z "$JWT_TOKEN" ] || [ ${#JWT_TOKEN} -lt 20 ]; then
    echo "❌ Failed to get JWT Token: $TOKEN_RES"
    exit 1
fi
echo "✅ JWT acquired (starts with: ${JWT_TOKEN:0:15}...)"

# 5. Access Service A
echo "📡 Calling Service-A with JWT..."
SERVICE_A_RES=$(curl -s -X GET "$BASE_URL/api/service-a/preferences" \
     -H "Authorization: Bearer $JWT_TOKEN")

if [[ $SERVICE_A_RES == *"preferences"* ]]; then
    echo "🎉 SUCCESS! Service-A Response:"
    echo "   $SERVICE_A_RES"
else
    echo "❌ Service-A Authorization Failed!"
    echo "   Response: $SERVICE_A_RES"
    exit 1
fi

# Cleanup
rm $COOKIE_FILE
echo "--------------------------------"
echo "🏁 Test Complete."
Replace TOKEN with your actual JWT
# TOKEN="eyJhbGciOiJFZERTQSIsImtpZCI6IlRKdXZzZGZXcTFBcnpFd2o1RWpGOFNlM29zNlUzSUtsIn0.eyJpYXQiOjE3Njk2MjU3NDEsIm5hbWUiOiJUZXN0IFVzZXIiLCJlbWFpbCI6InVzZXJAZXhhbXBsZS5jb20iLCJlbWFpbFZlcmlmaWVkIjpmYWxzZSwiaW1hZ2UiOm51bGwsImNyZWF0ZWRBdCI6IjIwMjYtMDEtMjhUMTg6NDI6MDYuNTQxWiIsInVwZGF0ZWRBdCI6IjIwMjYtMDEtMjhUMTg6NDI6MDYuNTQxWiIsImlkIjoiWExhWW5CVG5Gck5NUVBmRGRlSkF1Y3M1UFBTUTU3ZTgiLCJzdWIiOiJYTGFZbkJUbkZyTk1RUGZEZGVKQXVjczVQUFNRNTdlOCIsImV4cCI6MTc2OTYyOTM0MSwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4MDgxIiwiYXVkIjoiaHR0cDovL2xvY2FsaG9zdDo4MDgxIn0.JUjBbrpKlj95UYRjxGvjRPp23_viJjrZ8fcJd8dFwkjHuxBI8fXzFUQV5hqTAhQejthAEHyQbwigyyJiXza4Bw"
# echo $TOKEN | cut -d '.' -f 2 | base64 --decode | jq .