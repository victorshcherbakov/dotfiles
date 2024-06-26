#!/bin/bash

echo "Github:"
echo "1. Generate SSH key"
echo "  More info here: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key"
echo "  The command:"
echo "  ssh-keygen -t ed25519 -C your_email@example.com"
echo "2. Create ~/.ssh/config file"
cat ./templates/ssh_config
echo "3. Start the ssh-agent"
echo "4. Add your *.pub key to the GitHub account - https://github.com/settings/keys"
echo "  For the problem 'Bad owner or permissions on ssh config file' - https://superuser.com/questions/1212402/bad-owner-or-permissions-on-ssh-config-file"
echo "  chmod 700 ~/.ssh"
echo "  chmod 600 ~/.ssh/*"
echo "5. Add your SSH public key:"
echo "  ssh-add ~/.ssh/id_ed25519"
