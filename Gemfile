source 'https://gems.ruby-china.com'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.3'
# Use sqlite3 as the database for Active Record
gem 'mysql2'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
gem "non-stupid-digest-assets"

gem 'redis', '~> 3.3'
gem 'redis-namespace', '~> 1.5'
gem 'redis-rails', '~> 5.0'
gem 'redis-objects', '~> 1.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'kaminari', github: 'amatsuda/kaminari'
gem 'carrierwave'
gem 'jquery-rails'
gem 'remotipart', '~> 1.2'
gem 'cocoon'
gem 'simple_form'
gem 'default_where', github: 'jamst/default_where'

gem 'spreadsheet'
gem 'roo'

# 定时任务
gem 'whenever', require: false
# 日志数据存储
gem 'mongo'
gem 'mongoid'

# 图片处理
gem "mini_magick"

# 队列任务
gem 'sidekiq', '~> 4.2'
gem 'sidekiq-cron', '~> 0.4.5', require: false

# aliyun_oss
gem 'aliyun-sdk'

# 爬虫
# gem 'mechanize'
# gem 'spidr'
gem 'httparty'
gem 'click_house'

# Login & Authority
gem 'devise', git: 'https://github.com/plataformatec/devise.git'
gem 'cancancan'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'pry'
  gem 'pry-rails'

  gem 'mina', '~> 0.3.8', require: false
  gem 'mina-puma', :require => false
  gem 'mina-sidekiq', '~> 0.4.1', require: false
  gem 'mina-multistage', '~> 1.0', '>= 1.0.2', require: false

end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
