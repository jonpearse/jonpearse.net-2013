require 'bundler/capistrano'
load 'deploy/assets'

set :application, "jjp-lite"
set :repository,  "git@git.jonpearse.net:jjp-lite.git"

set :scm, :git

set :deploy_to, "/home/jon/sites/jjp-lite"

server "elysoun.jonpearse.net", :app, :web, :db, :primary => true

set :user, 'jon'
set :use_sudo, false
set :normalize_asset_timestamps, false

after "deploy:restart",             "deploy:cleanup"
before "deploy:assets:precompile",  "db:symlink"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

#If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :db do
  desc "Make symlink for database yaml" 
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
  end
end