#!/bin/bash

# Check if the input file is provided
if [ -z "$1" ]; then
    echo "Please provide the input file"
    exit 1
fi

# Read the input file, ignoring spaces after semicolon and comma use the or incase  eof is reached
while IFS=';' read -r username groups || [ -n "$username" ]; do
    # Trim leading and trailing whitespace from username and groups
    username=$(echo "$username" | tr -s '[:space:]' | xargs)
    groups=$(echo "$groups" | tr -s '[:space:]'| xargs)
   

    # Check if the user already exists
    if id "$username" &>/dev/null; then
        echo "User ${username} already exists, skipping..." >> /var/log/user_management.log
        continue
    fi

    # Create the user if it doesn't exist
    useradd -m -s /bin/bash "${username}"

    # Split the groups string by comma and create each group if it doesn't exist
    IFS=',' read -ra group_array <<< "$groups"
    for group in "${group_array[@]}"; do
        group=$(echo "$group" | tr -s '[:space:]' | xargs)
        if ! getent group "${group}" &>/dev/null; then
            groupadd "${group}"  
        fi
        usermod -aG "${group}" "${username}"
    done

    # Generate a random password
    password=$(openssl rand -base64 12)

    # Set the password and add it to the secure file
    echo "${username}:${password}" | chpasswd
    echo "${username},${password}" >> /var/secure/user_passwords.txt

    # Log the action
    echo "User ${username} created with groups ${groups} and password ${password}" >> /var/log/user_management.log
done < "$1"
echo "success"
