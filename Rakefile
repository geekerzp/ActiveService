###################################
# framework rake tasks            #
#                                 #
#                                 #
# rake constants                  #
# ENV['VERSION'] migrate版本号    #
# ENV['GGA_ENV'] rake数据库环境   #
###################################

# 加载核心模块
require './core/gga'

# 加载自定义tasks
Dir[File.dirname(__FILE__) + '/tasks/*.rake'].each {|r| import r }

# 数据库操作任务
namespace :db do
  desc "loads database configuration in for other db tasks to run"
  task :load_config do
    ActiveRecord::Base.configurations = db_conf
    GGA_ENV = ((ENV['GGA_ENV'] == 'production') || (ENV['GGA_ENV'] == 'development')) ?
                ENV['GGA_ENV'] : 'development'  # 默认为development

    # for PostgresSQL
    # drop and create need to be performed with a connection to the 'postgres' (system) database
    # ActiveRecord::Base.establish_connection db_conf["production"].merge('database' => 'postgres',
    #                                                                  'schema_search_path' => 'public')

    # for MySQL
    ActiveRecord::Base.establish_connection db_conf[GGA_ENV].merge('database' => 'mysql',
                                                                       'schema_search_path' => 'public')
  end

  desc "creates and migrates your database"
  task :setup => :load_config do
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
  end

  desc "migrate your database"
  task :migrate => :load_config do
    ActiveRecord::Base.establish_connection db_conf[GGA_ENV]

    ActiveRecord::Migrator.migrate(
      ActiveRecord::Migrator.migrations_paths,
      ENV["VERSION"] ? ENV["VERSION"].to_i : nil
    )
  end

  desc 'Drops the database'
  task :drop => :load_config do
    begin
      ActiveRecord::Base.connection.drop_database db_conf[GGA_ENV]['database']
    rescue
      puts "Database not exists #{e.message}"
    end
  end

  desc 'Creates the database'
  task :create => :load_config do
    begin
      ActiveRecord::Base.connection.create_database db_conf[GGA_ENV]['database']
    rescue => e
      puts "Database exists #{e.message}"
    end
  end
end

# 系统环境设定任务
desc "Set the enviroment"
task :environment do
  ActiveRecord::Base.configurations = db_conf
  GGA_ENV = ((ENV['GGA_ENV'] == 'production') || (ENV['GGA_ENV'] == 'development')) ?
              ENV['GGA_ENV'] : 'development'  # 默认为development
  ActiveRecord::Base.establish_connection db_conf[GGA_ENV]
end

# 读取数据库配置文件
def db_conf
  config = YAML.load(ERB.new(File.read('config/database.yml')).result)
end
