echo 'Starting Container DB installer'
echo ''

echo 'Please enter your AWS credentials for backups'
read -p 'AWS_SECRET_KEY: ' AWS_SECRET_KEY
read -p 'AWS_ACCESS_TOKEN: ' AWS_ACCESS_TOKEN
read -p 'AWS_BUCKET_NAME: ' AWS_BUCKET_NAME
echo 'Thanks...'
echo ''

# @todo test these keys work

echo 'Installing required packages'
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce -y pwgen
echo ''

# Pull the base images
echo 'Pulling required Docker images'
docker pull containerdb/backup-restore
docker pull containerdb/containerdb
docker pull postgres
docker pull mysql
docker pull tutum/redis
echo ''

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
HOST_IP=`curl ipinfo.io/ip` # Probably a better way to get our external IP, but this works for now
DB_URL="postgres://$DB_USERNAME:$DB_PASSWORD@$HOST_IP:$DB_PORT"
SECRET_KEY_BASE=`pwgen 50 1`
docker create --name containerdb_app -p 80:3000 -v /var/run/docker.sock:/var/run/docker.sock -e AWS_ACCESS_TOKEN=$AWS_ACCESS_TOKEN -e AWS_SECRET_KEY=$AWS_SECRET_KEY -e AWS_BUCKET_NAME=$AWS_BUCKET_NAME -e DATABASE_URL=$DB_URL -e RAILS_ENV=production -e SECRET_KEY_BASE=$SECRET_KEY_BASE -e HOST=$HOST_IP -e RAILS_SERVE_STATIC_FILES=true containerdb/containerdb /bin/bash -c "rake assets:precompile && rails s"
docker start containerdb_app

# Create the database and run migrations
docker exec containerdb_app rails db:create db:migrate

# Let Container DB manage it's own DB
docker exec containerdb_app rails r "Service.create!(service_type: :postgres, name: 'containerdb', port: $DB_PORT, container_id: '$DB_CONTAINER_ID', environment_variables: { 'POSTGRES_PASSWORD' => '$DB_PASSWORD', 'POSTGRES_USER' => '$DB_USERNAME'})"
echo ''
echo '...done'
echo 'Visit http://$HOST_IP'
