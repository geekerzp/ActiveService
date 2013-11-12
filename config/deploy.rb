##########################################
#            Capistrano配置脚本          #
#       功能：远程同步git服务器代码      #
##########################################
#require 'rvm/capistrano'

# 配置
set :user, 'onepiece'                   # ssh用户名
set :password, 'onepiece'               # ssh密码
set :web_servers, '42.121.6.191'        # web服务器
set :app_servers, '42.121.6.191'        # 应用服务器
set :db_servers_main, '42.121.6.191'    # 主数据库服务器
set :db_servers, '42.121.6.191'         # 从数据库服务器
set :domain, '42.121.6.191'             # 域名
set :application, "onepiece"            # 应用名称

# file paths
set :repository,  "gitolite:OnePiece_Server.git"            # git仓库
set :deploy_to, "/home/#{user}/server_for91/#{domain}"           # 应用路径

role :web, web_servers, :port => 22                              # Your HTTP server, Apache/etc
role :app, app_servers, :port => 22                             # This may be the same as your `Web` server
role :db,  db_servers_main, :primary => true, :port => 22        # This is where Rails migrations will run
role :db,  db_servers, :port => 22

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# miscellaneous options
# git配置
set :deploy_via, :remote_cache
set :scm, 'git'                   # scm软件管理配置
set :branch, 'new'                # 分支
set :scm_verbose, false           # 是否建立current目录

# 其他
set :use_sudo, false               # 是否默认使用sudo
default_run_options[:pty] = true   # 开启pty

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# 任务
# Capistrano自带很多任务，可以自定义
# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

# 自定义任务
namespace :deploy do
  # 重启Passenger
  desc "cause Passenger to initiate a restart"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "reload the database with seed data"
  task :seed do
    run "cd #{current_path}; rake db:seed RAILS_ENV=production"
  end

  # 启动nginx
  desc "start nginx"
  task :nginx_start do
    run "sudo /opt/nginx/sbin/nginx"
  end

  # 重启nginx
  desc "restart nginx"
  task :nginx_restart do
    run "sudo /opt/nginx/sbin/nginx -s reload"
  end

  # 关闭nginx
  desc "shut down nginx"
  task :nginx_stop do
    run "sudo pkill -9 nginx"
  end

end

# 在更新代码之后，执行bundle install
#after "deploy:update_code", :bundle_install
desc "install the necessary preprequisites"
task :bundle_install do
  run "cd #{release_path} && #{sudo} bundle install"
end


