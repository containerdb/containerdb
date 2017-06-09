namespace :users do
  task :create, [:email, :password] => :environment do |t, args|
    unless args[:email].present?
      puts 'Email is required'
      next
    end

    unless args[:password].present?
      puts 'Password is required'
      next
    end

    User.create!(email: args[:email], password: args[:password])
    puts 'Created'
  end
end
