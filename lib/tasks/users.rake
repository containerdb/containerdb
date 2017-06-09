namespace :users do
  task :create, [:email, :password] => :environment do |t, args|
    args.with_defaults(password: SecureRandom.hex.first(12))
    
    abort 'Email is required' unless args[:email].present?
    abort 'Password is required' unless args[:password].present?

    user = User.create!(email: args[:email], password: args[:password])
    puts "Created user #{user.email} with password #{args[:password]}"
  end
end
