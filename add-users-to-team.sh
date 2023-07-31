#!/bin/bash

# Set the Mattermost server URL.
MM_SERVICESETTINGS_SITEURL="http://localhost:8065"

# Set the name of the team you want to export users from
TEAM_NAME="Welcome"

# Create a function to authenticate with Mattermost
# Using Access_Token here
function authenticate() {
  API_TOKEN=$(cat api_token.txt)
  mmctl auth login $MM_SERVICESETTINGS_SITEURL --name localhost --access-token $API_TOKEN
}
authenticate

# Load CSV of users
CSV_FILE="users.csv"

# Create an empty list of usernames
usernames=()

# Read the CSV file and add the usernames to the list
while IFS="," read -r firstname lastname username email; do
    username=$(echo "$username" | sed 's/"//g')
    usernames+=($username)
done < $CSV_FILE

# Loop through the usernames and add to team
for username in ${usernames[@]}; do
    mmctl team users add $TEAM_NAME $username 
done
