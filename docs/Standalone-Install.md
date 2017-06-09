We have a standalone installer that will take an empty Ubuntu server and install everything you need to run Container DB.

```
# Add the Docker Repo
wget -qO - https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Add the Container DB Repo
wget -qO - https://deb.packager.io/key | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://deb.packager.io/gh/containerdb/containerdb $(lsb_release -cs) master"

# Install Container DB
sudo apt-get update && apt-get install containerdb -y
```
