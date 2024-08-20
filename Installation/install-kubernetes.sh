#!/bin/bash

# Create a user with a home directory
useradd -m hmohammadi

# Set the password for the user
echo "Please enter a password for the user 'hmohammadi':"
passwd hmohammadi

# Add the user to the sudo group
usermod -aG sudo hmohammadi

# Run the chsh command as the new user to set the default shell to /bin/bash
su - hmohammadi -c "chsh -s /bin/bash"

# Confirmation message
echo "User 'hmohammadi' has been created, added to the sudo group, a password has been set, and the default shell is set to /bin/bash."
