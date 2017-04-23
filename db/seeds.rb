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
  name: 'Test'
)
