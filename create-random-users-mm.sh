#!/bin/bash

# MM info
MM_ADMIN_USERNAME=mm_admin
MM_SERVICESETTINGS_SITEURL=http://localhost:8065
MM_ADMIN_PASSWORD=Pa55w0rd

# Initial Password for Users
password="Pa55w0rd1!"

# Number of records to generate
num_records=1000

# Function to generate a random first name
generate_first_name() {
    first_names=("John" "Jane" "Michael" "Emily" "William" "Olivia" "James" "Sophia" "Robert" "Ava" "David" "Isabella" "Joseph" "Mia" "Daniel" "Abigail" "Matthew" "Charlotte" "Christopher" "Harper")
    echo ${first_names[$((RANDOM % ${#first_names[@]}))]}
}

# Function to generate a random last name
generate_last_name() {
    last_names=("Smith" "Johnson" "Williams" "Jones" "Brown" "Davis" "Miller" "Wilson" "Taylor" "Clark" "Martinez" "Robinson" "Lewis" "Lee" "Walker" "Hall" "Allen" "Young" "Hernandez" "King")
    echo ${last_names[$((RANDOM % ${#last_names[@]}))]}
}

# Function to generate username
generate_username() {
    local first_name=$1
    local last_name=$2
    echo "$(echo ${first_name:0:1} | tr '[:upper:]' '[:lower:]').$(echo $last_name | tr '[:upper:]' '[:lower:]')${random_number}"
}

# Function to generate a random number
generate_random_number() {
    echo $((RANDOM % $num_records))  # Generates a random number between 0 and 999
}

# Function to generate email
generate_email() {
    local first_name=$1
    local last_name=$2
    local random_number=$3
    echo "$(echo ${first_name:0:1} | tr '[:upper:]' '[:lower:]').$(echo "$last_name" | tr '[:upper:]' '[:lower:]')${random_number}@example.com"
}

echo "First Name,Last Name,Username,Email" > random_users.csv

for ((i = 0; i < num_records; i++)); do
    first_name=$(generate_first_name)
    last_name=$(generate_last_name)
    random_number=$(generate_random_number)
    email=$(generate_email "$first_name" "$last_name" "$random_number")
    username=$(generate_username "$first_name" "$last_name" "$random_number")

  # Check for duplicates and regenerate email/username if necessary
    while [[ " ${generated_emails[@]} " =~ " ${email} " || " ${generated_usernames[@]} " =~ " ${username} " ]]; do
        random_number=$(generate_random_number)
        email=$(generate_email "$first_name" "$last_name" "$random_number")
        username=$(generate_username "$first_name" "$last_name")
    done

    # Add email and username to the arrays
    generated_emails+=("$email")
    generated_usernames+=("$username")

    echo "$first_name,$last_name,$username,$email" >> random_users.csv
done

echo "CSV file generated successfully."

# Create a function to authenticate with Mattermost
# Using Access_Token here
function authenticate() {
  API_TOKEN=$(cat api_token.txt)
  mmctl auth login $MM_SERVICESETTINGS_SITEURL --name localhost --access-token $API_TOKEN
}
authenticate

# Load CSV of mock users
csv_file="random_users.csv"

# Loop through the list of users from the CSV file and create them using mmctl
while IFS=',' read -r first_name last_name username email; do
  mmctl user create --username $username --firstname $first_name --lastname $last_name --email $email --password $password
done < "$csv_file"

# Get a list of all the users
all_users=$(mmctl user list --all)

# Randomly select 250 users to deactivate
deactivated_users=$(echo $all_users | shuf -n 250)

# Loop through the list of deactivated users and deactivate them using mmctl
for username in $deactivated_users; do
  mmctl user deactivate $username
done