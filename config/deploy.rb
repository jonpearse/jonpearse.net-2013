# config valid only for current version of Capistrano
lock '3.5.0'

set :application, 'jjp-lite'
set :repo_url,    'git@git.jonpearse.net:jjp-lite.git'

# Rails-specific
set :keep_assets, 1
set :conditionally_migrate, true

set :linked_dirs,  fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')
set :linked_files, fetch(:linked_files, []).push('config/database.yml')

# RVM
set :rvm_type, :user

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
