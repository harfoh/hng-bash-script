#!/bin/bash

# Check if the text file is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <name-of-the-text-file>"
    exit 1
fi

# Create a secure directory to store passwords if it doesn't exist
if [ ! -d /var/secure ]; then
    sudo mkdir /var/secure
    sudo chown root:root /var/secure
    sudo chmod 700 /var/secure
    echo "$(date) - Created /var/secure directory" >> /var/log/user_management.log
fi

# Create groups mentioned in the text file
while IFS=';' read -r username groups; do
    # Skip if username is empty
    if [ -z "$username" ]; then
        echo "$(date) - Skipping empty username" >> /var/log/user_management.log
        continue
    fi

    # Read and create groups
    IFS=',' read -ra grp_array <<< "$groups"
    for grp in "${grp_array[@]}"; do
        if ! grep -q "^$grp:" /etc/group; then
            sudo groupadd "$grp"
            echo "$(date) - Created group $grp" >> /var/log/user_management.log
            echo "$(date) - Created group $grp" >> /var/log/created_groups.log
        else
            echo "$(date) - Group $grp already exists. Skipping group creation." >> /var/log/user_management.log
        fi
    done
done < "$1"

# Read the text file line by line to create users and assign them to groups
while IFS=';' read -r username groups; do
    # Skip if username is empty
    if [ -z "$username" ]; then
        echo "$(date) - Skipping empty username" >> /var/log/user_management.log
        continue
    fi

    # Check if the user already exists
    if id "$username" &>/dev/null; then
        echo "User $username already exists. Skipping..."
        echo "$(date) - User $username already exists. Skipping..." >> /var/log/user_management.log
        continue
    fi

    # Create a primary group for the user if it doesn't exist
    if ! grep -q "^$username:" /etc/group; then
        sudo groupadd "$username"
        echo "$(date) - Created group $username" >> /var/log/user_management.log
    else
        echo "$(date) - Group $username already exists. Skipping group creation." >> /var/log/user_management.log
    fi

    # Create the user and assign to groups
    user_groups=""
    IFS=',' read -ra grp_array <<< "$groups"
    for grp in "${grp_array[@]}"; do
        if grep -q "^$grp:" /etc/group; then
            user_groups+="$grp,"
        else
            echo "$(date) - Group $grp does not exist. Skipping group $grp for user $username" >> /var/log/user_management.log
        fi
    done

    # Remove trailing comma if any
    user_groups=${user_groups%,}

    # Create the user with valid groups
    sudo useradd -m -g "$username" -G "$user_groups" "$username"
    if [ $? -eq 0 ]; then
        echo "$(date) - Created user $username and added to groups: $user_groups" >> /var/log/user_management.log
        echo "$(date) - Created user $username" >> /var/log/created_users.log

        # Generate a random password
        password=$(openssl rand -base64 12)
        echo "$(date) - Generated password for $username" >> /var/log/user_management.log

        # Set the password for the user
        echo "$username:$password" | sudo chpasswd
        if [ $? -eq 0 ]; then
            echo "$(date) - Set password for $username" >> /var/log/user_management.log
            # Store passwords securely
            echo "$username,$password" >> /var/secure/user_passwords.txt
            echo "$(date) - Stored password for $username in /var/secure/user_passwords.txt" >> /var/log/user_management.log
        else
            echo "$(date) - Failed to set password for $username" >> /var/log/user_management.log
        fi
    else
        echo "$(date) - Failed to create user $username" >> /var/log/user_management.log
    fi

done < "$1"

# Set permissions for user_passwords.txt
sudo chown root:root /var/secure/user_passwords.txt
sudo chmod 600 /var/secure/user_passwords.txt
echo "$(date) - Set permissions for /var/secure/user_passwords.txt" >> /var/log/user_management.log

echo "Script execution completed. Check /var/log/user_management.log for details."

