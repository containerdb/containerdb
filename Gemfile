source 'https://rubygems.org'

# Default to 2.3.4 but allow override for development
ruby File.exist?('.ruby-version') ? File.read('.ruby-version') : '2.3.4'

gem 'rails', '~> 5.0.0', '>= 5.0.0.1'

gem 'bootstrap-sass'
gem 'devise'                                   # Authentication
gem 'docker-api'
gem 'haml'
gem 'jquery-rails'
gem 'pg'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'sidekiq'                                  # Background jobs
gem 'simple_form'
gem 'turbolinks', '~> 5'
gem 'uglifier', '>= 1.3.0'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'rspec-rails'
  gem 'simplecov', require: false              # Code coverage
end

group :development do
  gem 'dotenv-rails', require: 'dotenv/rails-now'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console'
end
