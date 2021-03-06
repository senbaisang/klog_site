# -*- encoding : utf-8 -*-
require 'capistrano-rbenv'
load 'deploy/assets'
SSH_USER = 'ubuntu'
ssh_options[:port] = 35250
set :rake, "bundle exec rake"
set :application, "shuanglei_blog"
set :repository, "."
set :scm, :none
set :deploy_via, :copy
server = "119.254.210.200"

role :web, server
role :app, server
role :db,  server, :primary => true
role :db,  server

set :deploy_to, "/opt/app/shuanglei"
default_run_options[:pty] = true

# change to your username
set :user, SSH_USER

namespace :deploy do
  task :start do
    run "cd #{release_path} && bundle exec thin start -C config/thin.yml"
  end
  task :stop do
    run "cd #{release_path} && bundle exec thin stop -C config/thin.yml"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    db_migrate
    stop
    sleep 2
    start
  end
  task :db_migrate do
    run "cd #{release_path} && bundle install"
    run "cd #{release_path} && bundle exec rake db:create db:migrate RAILS_ENV=production"
  end

  namespace :assets do
    task :precompile do
  #    puts "======= should run precompile"
  #    command = "cd #{release_path} && bundle exec rake RAILS_ENV=production RAILS_GROUPS=assets assets:precompile "
  #    puts "== please run == \n #{command} \n == manually after deploy is done"
      #run "bundle install"
      #run "cd #{release_path} && bundle exec rake RAILS_ENV=production RAILS_GROUPS=assets assets:precompile "
    end
  end
end


desc "Copy database.yml to release_path"
task :cp_database_yml do
  puts "=== executing my customized command: "
  run "cp -r #{shared_path}/config/* #{release_path}/config/"
  run "ln -s #{shared_path}/files #{release_path}/public/files "
  # 因为在开发机器上会存在这个文件夹，所以需要先把它删掉，再 ln
  run "rm #{release_path}/public/uploads -rf"
  run "ln -s #{shared_path}/public/uploads #{release_path}/public/uploads"
  puts "=== done (executing my customized command)"
end

before "deploy:assets:precompile", :cp_database_yml
#after "deploy", "deploy:restart"
