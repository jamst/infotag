puts 'use production1'

set :user, 'deploy'
set :domain, '47.112.127.18'
set :deploy_to, '/var/www/infotag'
set :repository, 'git@120.25.197.197:/home/git/infotag'
set :branch, 'master'
set :rails_env, 'production'
