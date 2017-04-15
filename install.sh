sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce -y

# Pull the base images
docker pull containerdb/backup-restore
docker pull containerdb/containerdb
docker pull postgres
docker pull mysql
docker pull tutum/redis

# Create a postgres container
# Install this app's Docker image
# Run this app using the PG container from above
# Run migrations
# Add the PG container to this app's DB so it can self manage
