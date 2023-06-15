#!/usr/bin/bash

# Install java
sudo apt -y update
sudo apt -y install openjdk-17-jdk-headless

# Create mincraft folder
mkdir /home/ubuntu/minecraft_server
cd /home/ubuntu/minecraft_server

# Get latest server.jar file
curl https://launchermeta.mojang.com/mc/game/version_manifest.json -o manifest.json

PYTHON_CODE=$(cat <<END
import json
f = open('manifest.json')

manifest = json.load(f)
latest_ver = manifest['latest']['release']
vers = manifest['versions']
for ver in vers:
        if ver['id'] == latest_ver:
                print(ver['url'])
                exit()
END
)

VERSION_URL=$(python3 -c "$PYTHON_CODE")
curl $VERSION_URL -o versions.json
JAR_URL=$(cat versions.json |\
        python3 -c "
import sys, json;
print(json.load(sys.stdin)['downloads']['server']['url'])")
curl $JAR_URL -o server.jar
rm manifest.json versions.json
sudo chown ubuntu:ubuntu server.jar

echo "eula=true" > eula.txt
sudo chown ubuntu:ubuntu eula.txt

# Create the server start script
cat << EOF > start_server.sh
#!/usr/bin/bash

java -Xmx1G -Xmx1G -jar server.jar
EOF
chmod 774 start_server.sh
sudo chown ubuntu:ubuntu start_server.sh

# Create service file to enable auto-starting of minecraft server
sudo touch /etc/systemd/system/minecraft_server.service
cat << EOF > /etc/systemd/system/minecraft_server.service
[Unit]
Description=Starts our minecraft server
After=network.target

[Service]
WorkingDirectory=/home/ubuntu/minecraft_server
ExecStart=/home/ubuntu/minecraft_server/start_server.sh
User=ubuntu
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable minecraft_server.service

# Start the service
sudo systemctl start minecraft_server
