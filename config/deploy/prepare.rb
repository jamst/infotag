puts 'use prepare'

set :user, 'deploy'
set :domain, '47.112.100.246'
set :deploy_to, '/var/www/infotag'
set :repository, 'git@120.25.197.197:/home/git/infotag'
set :branch, 'prepare'
set :rails_env, 'prepare'
