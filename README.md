# AWS EC2 continous deployer

A script that setup webhook on your instance to pull code from your github repo, on every push made to the repository. 
This helps you set up CI-CD framework on your EC2 instance free of cost.

# Screenshot
![Imgur](https://i.imgur.com/QccI0uc.jpg)

![Imgur](https://i.imgur.com/zlTdtey.jpg)

# How it works?

- On every push made from your local system to your git repository, your repo provider (bitbucket or github) shall post a payload.
- The payload is send as POST request to your webhook. This webhook is set up by the script.
- The webhook constantly listens to any incoming requests and perform credentials and payload matching.
- On a successful match, the code is pulled from the relevant branch and is deployed with zero downtime on your app.

# Installation

- Clone this repo on your server.
- Run `./deployer.sh` and then follow the below steps.

# Important Steps

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
