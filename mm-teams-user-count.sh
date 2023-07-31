#!/bin/bash

# Set the Mattermost server URL.
MM_SERVICESETTINGS_SITEURL="http://localhost:8065"

# Create a function to authenticate with Mattermost
# Using Access_Token here
function authenticate() {
  API_TOKEN=$(cat api_token.txt)
  mmctl auth login $MM_SERVICESETTINGS_SITEURL --name localhost --access-token $API_TOKEN
}
authenticate

# Lists the Team names and number of users per team

# Set headers for CSV file
echo "team_name,users" > team_users.csv

# Save team names to a variable
team_names=$(mmctl team list | awk -F ' ' '{print $1}')

# Loop through team names and append to CSV file
for team_name in $team_names; do
  user_count=$(mmctl user list --team $team_name | wc -l)
  echo "$team_name,$user_count" >> team_users.csv
done
