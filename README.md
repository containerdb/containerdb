# Container DB

Create databases instantly, with automatic backups. Perfect for prototyping and running small apps.

![](http://d.pr/i/jyZn+)

### Dependencies

 - Ubuntu 16.04 (may work on lower, but not tested yet)
 - Docker (Installed Automatically)
 - Postgres (Installed Automatically)
 - Nginx (Installed Automatically)
 - Redis (Installed Automatically)

### Install

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

### Upgrade

```
apt-get update && apt-get install containerdb
```

### Databases

- MySQL
- Postgres
- Redis

### Features

- Instantly launch a database
- Connect to the database from anywhere
- Password protected databases
- Manually backup to Amazon S3

### Roadmap

- Automated Backups
- Restore backups
- Download backups
- User management
- Database clusters (maybe - long term)
