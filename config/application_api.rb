#
# 配置文件
#

# Heroku云服务器PaaS环境
# Sets up database configuration
db = URI.parse(ENV['DATABASE_URL'] || 'http://localhost')
if db.scheme == 'postgres' # Heroku environment
  ActiveRecord::Base.establish_connection(
    :adapter  => db.scheme == 'postgres' ? 'em_postgresql' : db.scheme,
    :host     => db.host,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8'
  )
# 本地环境
else # local environment
  # Database Enviroment
  # $ ruby server.rb -e production 会传递给 Goliath.env?
  env = Goliath.env?('development') ? 'development' : 'production'
  db = YAML.load(ERB.new(File.read('config/database.yml')).result)[env]
  ActiveRecord::Base.establish_connection(db)

  # ActiveRecord Logger
  ActiveRecord::Base.logger = Grape::API.logger

  # GGA Logger
  GGA.logger = Grape::API.logger

  # 自定义系统Log的输出样式
  GGA.sys_log do |env, response, elapsed_time| 
    method = env[Goliath::Request::REQUEST_METHOD]
    path   = env[Goliath::Request::REQUEST_URI]

    env[Goliath::Request::RACK_LOGGER].info("#{response.status} #{method} #{path} in #{'%.2f' % elapsed_time } ms")
  end 

  # cache_store 设置缓存（目前只支持Redis）
  CACHE = EventMachine::Synchrony::ConnectionPool.new(size: 100) do 
    ActiveSupport::Cache.lookup_store :redis_store, 
      { :host => "localhost", :port => "6379", :driver => :synchrony, :expires_in => 1.week }    
  end 
  CACHE.logger = GGA.logger

  SecondLevelCache.configure do |config|
    config.cache_store      = CACHE
    config.logger           = GGA.logger
    config.cache_key_prefix = 'onepiece'
  end 

  # websocket
  config['channel'] = EM::Channel.new
end
