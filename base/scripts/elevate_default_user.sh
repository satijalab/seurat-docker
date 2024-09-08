#!/bin/bash

# ensure the script is run with sudo privileges
if [[ "$EUID" -ne 0 ]]; then
   echo "This script must be run with sudo privileges."
   exit 1
fi

# set default values
USERNAME="default_user"
PASSWORD="password"

# add the user and set the password
useradd -m "$USERNAME" \
    && echo "${USERNAME}:${PASSWORD}" | chpasswd

# grant the user sudo privileges without requiring a password
echo "$USERNAME ALL=(root) NOPASSWD:ALL" | tee /etc/sudoers.d/"$USERNAME" > /dev/null \
    && chmod 0440 /etc/sudoers.d/"$USERNAME"

echo "User $USERNAME has been created and granted sudo privileges."
