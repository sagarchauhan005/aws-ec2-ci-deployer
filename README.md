# AWS EC2 continous deployer

A script that setup webhook on your instance to pull code from your github repo, on every push made to the repository. 
This helps you set up CI-CD framework on your EC2 instance free of cost.

# Screenshot
![Imgur](https://i.imgur.com/QccI0uc.jpg)

![Imgur](https://i.imgur.com/zlTdtey.jpg)

# How it works?

- On every push made from your local system to your git repository, your repo provider (bitbucket or github) shall post a payload.
- The payload is sent as POST request to your webhook. This webhook is set up by the script.
- The webhook constantly listens to any incoming requests and perform credentials and payload matching.
- On a successful match, the code is pulled from the relevant branch and is deployed with zero downtime on your app.

# Installation

- Login to your server using root user and type `cd ` to get into root directory.
- Clone this repo on your server at the root directory.
  `git clone https://github.com/sagarchauhan005/aws-ec2-continous-deployer.git`
- Make sure the server firewall and AWS Security Groups has allowed 9000 port access.
- Go to your app root directory and git clone your directory by running the following command :
  - `git clone --depth 1 -b <branch> <repo_url>`
- The above command makes sure that no extra branches and commit history is pulled in.
- Run `./deployer.sh` and then follow the steps.
- Make sure to enter the absolute path for your app. The path is ends at the root level of your app, do not go beyond that.  
- Once all the steps are completed, visit the app in your app folder and run:
  - ` git fetch origin <branch`
- This shall add the new host key generated in your known_hosts file for future push or pull.
- [**Important**] If it is a front-end app, 
  - Make sure to make changes in the `apache.conf` file for the respective app as well.
      `/srv/users/serverpilot/apps/store-app/public => /srv/users/serverpilot/apps/store-app/dist`
  - Ask the developer to copy `.htaccess` file from root folder to `public` folder in the app, so that during the build, it is pushed to the server.  
- Once all this is done, ask the developer to push a new change from local system to the concerned branch.

# Error Description

- `Hooks not found` OR `Hooks not satisfied`
   - Webhook was not setup correctly, check `webhook/hooks.json` file for any possible error in json formatting
   - If any issue found, fix it and then run :
      ```
     cp -R webhook/hooks.json /etc/webhook.conf
     service webhook restart
     ```
- `git command is failing due to some reason`
   - Check the `remote` path in `.git/config` file. After running `deployer.sh` it should be changed to `ssh` link from `https` link.
   - SSH key fingerprint wasn't added for first time git pull or push.
  
- `Front-end app is not reachable`
  - Check for the `.htaccess` file or `apache.conf` file for appropriate configuration.

- `Any issues with webhook`
  - Try running `service webhook restart` or `service ssh restart`
  - Enable `webhook history` in bitbucket to check the success of webhook calls.
  
# Important Steps

- Use this command ONLY to clone any repo : 
  `git clone --depth 1 -b <branch> <repo_url>`
- Make sure to enter **SSH** git clone path and not **HTTPS** git clone path. 
- Paste the webhook url in your repository settings under hooks. For bitbucket, make sure to check SSL checkbox, it shall not check for SSL url then
- Copy and paste the public key that the scripts prints into your repository keys setting.

# Author

[Sagar Chauhan](https://twitter.com/chauhansahab005) works as a Project Manager - Technology at [Greenhonchos](https://www.greenhonchos.com).
In his spare time, he hunts bug as a Bug Bounty Hunter.
Follow him at [Instagram](https://www.instagram.com/chauhansahab005/), [Twitter](https://twitter.com/chauhansahab005),  [Facebook](https://facebook.com/sagar.chauhan3),
[Github](https://github.com/sagarchauhan005)

# License
MIT
