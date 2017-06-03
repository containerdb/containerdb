User.delete_all
Service.delete_all
StorageProvider.delete_all

user1 = User.create!(
  email: 'user1@example.com',
  password: 'password',
  password_confirmation: 'password',
)

StorageProvider.create!(
  provider: :s3,
  name: 'Test S3',
  environment_variables: {
    'AWS_ACCESS_TOKEN': 'nothing',
    'AWS_SECRET_KEY': 'nothing',
    'AWS_BUCKET_NAME': 'nothing',
  }
)

StorageProvider.create!(
  provider: :local,
  name: 'Test Local',
  environment_variables: {
    'DIRECTORY': '/tmp/containerdb_backups'
  }
)
