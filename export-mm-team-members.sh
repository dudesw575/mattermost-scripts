#!/bin/bash

# Set the name of the team you want to export users from
TEAM_NAME="Welcome"

# Create the export file
EXPORT_FILE="users.csv"

# Set the Mattermost server URL.
MM_SERVICESETTINGS_SITEURL="http://localhost:8065"

# Create a function to authenticate with Mattermost
# Using Access_Token here
function authenticate() {
  API_TOKEN=$(cat api_token.txt)
  mmctl auth login $MM_SERVICESETTINGS_SITEURL --name localhost --access-token $API_TOKEN
}
authenticate

echo "First Name,Last Name,Username,Email" > $TEAM_NAME-users.csv
# Export users form selected Team to a CSV
mmctl user list --team $TEAM_NAME --all --json | jq -r '.[] | [.first_name, .last_name, .username, .email] | join(",")' >> $TEAM_NAME-users.csv