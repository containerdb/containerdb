#!/usr/bin/env bash
chown containerdb /var/run/docker.sock
docker pull containerdb/backup-restore
docker pull postgres
docker pull mysql
docker pull tutum/redis

# Setup for the first time
if ! containerdb config:get DATABASE_URL 2>/dev/null; then
  echo ''
  echo 'Lets configure Container DB'
  echo ''

  # There is probably a better way to get the external hostname, but this works nicely for now
  HOST_IP=`curl ipinfo.io/ip 2>/dev/null;`

  while [[ -z "$HOST_NAME" ]]
  do
    read -p "Hostname: " -e -i $HOST_IP HOST_NAME
  done
  echo

  echo 'And now lets setup your first user'
  while [[ -z "$ADMIN_EMAIL" ]]
  do
    read -p "Admin Email: " -e ADMIN_EMAIL
  done

  while [[ -z "$ADMIN_PASSWORD" ]]
  do
    read -s -p "Admin Password: " -e ADMIN_PASSWORD
  done
  echo
  
  echo
  read -p "Do you want to setup Amazon S3 backups? (y/N) " -n 1 -r -e SETUP_S3
  if [[ $SETUP_S3 =~ ^[Yy]$ ]]
  then
    while [[ -z "$AWS_SECRET_KEY" ]]
    do
      read -p "AWS_SECRET_KEY: " -e AWS_SECRET_KEY
    done

    while [[ -z "$AWS_ACCESS_TOKEN" ]]
    do
      read -p "AWS_ACCESS_TOKEN: " -e AWS_ACCESS_TOKEN
    done

    while [[ -z "$AWS_BUCKET_NAME" ]]
    do
      read -p "AWS_BUCKET_NAME: " -e AWS_BUCKET_NAME
    done

    echo
    echo 'Thanks... carrying on'
    echo
    configured_backups=true
  else
    configured_backups=false
  fi

  # Create the Postgres Container
  echo 'Setting up a Postgres container'
  DB_PORT=8474
  DB_USERNAME='postgres'
  DB_PASSWORD=`date +%s | sha256sum | base64 | head -c 32 ; echo`
  DB_CONTAINER_ID=`docker create --name containerdb_postgres -p $DB_PORT:5432 -e POSTGRES_PASSWORD=$DB_PASSWORD -e POSTGRES_USER=$DB_USERNAME postgres`
  docker start containerdb_postgres
  sleep 5 # @todo wait for the postgres container to start
  echo

  # Create the Redis Container
  echo 'Setting up a Redis container'
  REDIS_PORT=8475
  REDIS_PASS=`date +%s | sha256sum | base64 | head -c 32 ; echo`
  REDIS_CONTAINER_ID=`docker create --name containerdb_redis -p $REDIS_PORT:6379 -e REDIS_PASS=$REDIS_PASS tutum/redis`
  docker start containerdb_redis
  sleep 5 # @todo wait for the redis container to start
  echo

  # Setup Container DB configs
  echo 'Setting Environment Variables'
  sudo containerdb config:set HOST=$HOST_NAME
  sudo containerdb config:set REDIS_URL="redis://:$REDIS_PASS@127.0.0.1:$REDIS_PORT"
  sudo containerdb config:set DATABASE_URL="postgres://$DB_USERNAME:$DB_PASSWORD@127.0.0.1:$DB_PORT"

  # Scale up the app
  echo 'Starting Container DB'
  sudo containerdb scale web=2 sidekiq=2
  sudo service containerdb restart
  echo

  echo 'Create and Migrate the database'
  sudo containerdb run rails db:create db:migrate
  sudo containerdb run rails r "User.create!(email: '$ADMIN_EMAIL', password: '$ADMIN_PASSWORD')"
  echo

  # Create the storage provider
  if $configured_backups; then
    echo 'Save the Storage Provider'
    sudo containerdb run rails r "StorageProvider.create!(provider: :s3, name: 's3-$AWS_BUCKET_NAME', environment_variables: { 'AWS_BUCKET_NAME' => '$AWS_BUCKET_NAME', 'AWS_SECRET_KEY' => '$AWS_SECRET_KEY', 'AWS_ACCESS_TOKEN' => '$AWS_ACCESS_TOKEN'})"
    echo
  fi

  # Add the Postgres and Redis containers to the app so it can self manage them
  echo 'Save the Redis and Postgres Servies'
  sudo containerdb run rails r "Service.create!(backup_storage_provider_id: StorageProvider.first.try(:id), locked: true, service_type: :postgres, name: 'containerdb_postgres', port: $DB_PORT, container_id: '$DB_CONTAINER_ID', environment_variables: { 'POSTGRES_PASSWORD' => '$DB_PASSWORD', 'POSTGRES_USER' => '$DB_USERNAME'})"
  sudo containerdb run rails r "Service.create!(backup_storage_provider_id: StorageProvider.first.try(:id), locked: true, service_type: :redis, name: 'containerdb_redis', port: $REDIS_PORT, container_id: '$REDIS_CONTAINER_ID', environment_variables: { 'REDIS_PASS' => '$REDIS_PASS' })"
  echo

  # Backup Postgres and Redis for the first time
  if $configured_backups; then
    echo 'Perform initial backups'
    sudo containerdb run rails r "Service.where(name: 'containerdb_postgres', locked: true).first.backup(inline: true)"
    sudo containerdb run rails r "Service.where(name: 'containerdb_redis', locked: true).first.backup(inline: true)"
    echo
  fi

  echo 'Setup Nginx'
  cat > /etc/nginx/sites-available/default <<EOF
server {
  listen 80;
  location / {
    proxy_pass http://localhost:6000;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header Host \$http_host;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_redirect off;
  }
}
EOF

  sudo service nginx restart
  echo
else
  sudo containerdb run rails r "Service.where(name: 'containerdb_postgres', locked: true).first.backup(inline: true)"
  sudo containerdb run rails db:migrate
  sudo service containerdb restart
fi

echo
echo '...done'
echo
echo "Visit http://$(sudo containerdb config:get HOST)"
