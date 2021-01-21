#!/usr/bin/env bash

RED="\033[1;31m\n"
NOCOLOR="\033[0m\n"
YELLOW='\033[0;33m'
GREEN='\033[0;32m'

if [[ $EUID -ne 0 ]]; then
   printf "${RED}This script must be run as root${NOCOLOR}"
   exit 1
fi

printf "${GREEN}Enter the name of the app you wish to deploy (avoid spaces and special character)${NOCOLOR}"
read -r app_name
hostname="github.com-$app_name"

printf "${YELLOW}Configuring deployment for $app_name.${NOCOLOR}"

sleep 1

command -v git >/dev/null 2>&1 ||
{ echo >&2 "Git is not installed. Installing..";
  yum install git
}

command -v go >/dev/null 2>&1 ||
{ echo >&2 "Go is not installed. Installing..";
  apt  install golang-go
}

command -v webhook >/dev/null 2>&1 ||
{ echo >&2 "Please wait while we install the package. Installing..";
  sudo apt-get install webhook
}
cd "$HOME" || exit

app_hook="$HOME/$app_name/webhooks"
cwd="$HOME/$app_name/deployment/"
hjson="$HOME/$app_name/webhooks/hooks.json"
deploy_script="$HOME/$app_name/webhooks/deploy.sh"

rm -r "$app_name"
mkdir "$app_name" || exit
mkdir "$app_hook"
mkdir "$cwd"
touch "$hjson"
touch "$deploy_script"


#write to deployer script
{
  echo "#!/bin/bash"
  echo "mkdir done"
} >> "$deploy_script"

chmod +x "$deploy_script"

sleep 1
printf "${GREEN}Enter your secret key${NOCOLOR}"
read -r secret

command -v jq >/dev/null 2>&1 ||
{ echo >&2 "Jq is not installed. Installing..";
  apt install jq
}
sleep 1
jq -n --arg id "$app_name" \
      --arg cwd "$cwd" \
      --arg deployer "$deploy_script" \
      --arg secret "$secret" \
      --arg deploy_script "$deploy_script" \
'[{"id": $id,"execute-command": $deploy_script,"command-working-directory": $cwd,"response-message": "Executing deploy script...","trigger-rule": {"match": {"type": "payload-hash-sha1","secret": $secret,"parameter": {"source": "header","name": "X-Hub-Signature"}}}}]' > "$hjson"

sleep 1
printf "${GREEN} Copied webhook to etc.${NOCOLOR}"
cp -R "$hjson" "/etc/webhook.conf"
sleep 1
printf "${YELLOW}Please enter the git repository link (without clone command).${NOCOLOR}"
read -r git_repo

sleep 1
printf "${YELLOW}Initializing git in cwd.${NOCOLOR}"
cd "$cwd" || exit
git init
git remote add origin "$git_repo"

cd "$HOME" || exit

printf "${GREEN}Enter your server IP${NOCOLOR}"
sleep 1
read -r server_ip
webhook -hooks "$hjson" -ip "$server_ip"

printf "${GREEN}Generating SSH keys${NOCOLOR}"
email="$app_name@greenhonchos.com"

hostalias="$hostname"
keypath="$HOME/.ssh/${hostname}_rsa"
keypath_pub="$HOME/.ssh/${hostname}_rsa.pub"
ssh-keygen -t rsa -C "$email" -f "$keypath"
if [ $? -eq 0 ]; then
cat >> ~/.ssh/config <<EOF
Host $hostalias
        Hostname github.com
        User git
        AddKeysToAgent yes
    IdentitiesOnly yes
        IdentityFile $keypath
EOF
fi
sleep 1
# Issue is in ssh key generation`
#echo -e "\n\n\n" | ssh-keygen -t rsa -N ""
#mv "$app_name.key" "/root/.ssh"
#sleep 1
printf "${GREEN} Please copy paste the below mentioned ssk keys and paste into your repo settings.${NOCOLOR}"
sleep 1
cat "$keypath_pub"
#mv "$app_name.key.pub" "/root/.ssh"
#chmod 400 "/root/.ssh/$app_name.key.pub"
#ssh-add "/root/.ssh/$app_name.key"
sleep 1
printf "${GREEN} Restarted webhook.${NOCOLOR}"
service webhook restart