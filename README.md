# Container DB

Create databases instantly, with automatic backups. Perfect for prototyping and running small apps.

![](http://d.pr/i/jyZn+)

### Dependencies

 - Ubuntu 16.04 (may work on lower, but not tested yet)

### Install

```
# Add the Docker Repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Add the Container DB Repo
wget -qO - https://deb.packager.io/key | sudo apt-key add -
echo "deb https://deb.packager.io/gh/containerdb/containerdb xenial master" | sudo tee /etc/apt/sources.list.d/containerdb.list

# Install Container DB
sudo apt-get update
sudo apt-get install containerdb
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
