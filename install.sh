echo 'Starting Container DB installer'
echo ''

if hash containerdb 2>/dev/null; then
  installed=true
else
  installed=false
fi

# Is it already installed?
if ! $installed; then
  echo 'Please enter your AWS credentials for backups'
  read -p 'AWS_SECRET_KEY: ' AWS_SECRET_KEY
  read -p 'AWS_ACCESS_TOKEN: ' AWS_ACCESS_TOKEN
  read -p 'AWS_BUCKET_NAME: ' AWS_BUCKET_NAME
  echo 'Thanks...'
  echo ''
fi

# @todo test these keys work
echo 'Installing required packages'
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common

# Add the ContainerDB package
wget -qO - https://deb.packager.io/key | sudo apt-key add -
echo "deb https://deb.packager.io/gh/containerdb/containerdb xenial master" | sudo tee /etc/apt/sources.list.d/containerdb.list

# Add Docker page
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install packages
sudo apt-get update
sudo apt-get install docker-ce pwgen containerdb nginx -y
echo ''

# Pull the base images
echo 'Pulling required Docker images'
docker pull containerdb/backup-restore
docker pull postgres
docker pull mysql
docker pull tutum/redis
echo ''

HOST_IP=`curl ipinfo.io/ip` # Probably a better way to get our external IP, but this works for now

if ! $installed; then
  echo 'Installing Container DB'

  # Create the Postgres Container
  DB_PORT=8474
  DB_USERNAME='postgres'
  DB_PASSWORD=`pwgen 15 1`
  DB_CONTAINER_ID=`docker create --name containerdb_db -p $DB_PORT:5432 -e POSTGRES_PASSWORD=$DB_PASSWORD -e POSTGRES_USER=$DB_USERNAME postgres`

  # Start the DB Container
  docker start containerdb_db
  sleep 5 # @todo wait for the DB container to start

  # Create the app
  DB_URL="postgres://$DB_USERNAME:$DB_PASSWORD@$HOST_IP:$DB_PORT"

  sudo containerdb config:set AWS_ACCESS_TOKEN=$AWS_ACCESS_TOKEN AWS_SECRET_KEY=$AWS_SECRET_KEY AWS_BUCKET_NAME=$AWS_BUCKET_NAME DATABASE_URL=$DB_URL HOST=$HOST_IP
  sudo containerdb scale web=1

  cat > /etc/nginx/sites-available/default <<EOF
server {
  listen          80;
  location / {
    proxy_pass      http://localhost:6000;
  }
}
EOF

  sudo service nginx containerdb restart

  sudo containerdb run rails db:create db:migrate
  sudo containerdb run rails r "Service.create!(service_type: :postgres, name: 'containerdb', port: $DB_PORT, container_id: '$DB_CONTAINER_ID', environment_variables: { 'POSTGRES_PASSWORD' => '$DB_PASSWORD', 'POSTGRES_USER' => '$DB_USERNAME'})"
else
  sudo containerdb run rails db:migrate
fi

echo ''
echo '...done'
echo "Visit http://$HOST_IP"
