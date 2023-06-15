# Background
This repo contains everything necesarry to setup a minecraft server on an AWS
instance automatically.All that needs to be done is run a single command.
# Requirements
Install terraform and aws-cli-v2 before using this repo, as they are required tools.

Additionally, create a credentials file `~/.aws/credentials` and fill in the following information with your own AWS credentials.
```
[default]
aws_access_key_id=
aws_secret_access_key=
aws_session_token=
```
# Creating the Minecraft server and EC2 instance
Run the following two commands to automatically create the EC2 instance and
configure it to host the minecraft server:

```bash
$ terraform init
$ terraform apply
```
Type `yes` when prompted, and wait a few minutes for everything to set itself
up. The public IP address for the minecraft server will be displayed to the
screen.
# Connecting to the Minecraft server
Open the minecraft client and go to `Multiplayer`, then click `Direct
Connection` and type the IP address that displayed on the screen, and press
`Join Server` to join the server.

# Managing the Server
If you need to manually interact with the server files, you can use the
following command to SSH into the EC2 instance:  
`ssh ubuntu@PUBLIC_IP -i minecraft-key-pair.pem`
The server files are located in the home directory in a folder called `minecraft_server`
