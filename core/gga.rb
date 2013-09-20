require 'rubygems'
require 'bundler/setup'
require 'active_support'
require 'em-synchrony/activerecord'
require 'em-synchrony/mysql2'
require 'protected_attributes'    # rails4的ActiveRecord将attr_accessible类宏移到了Gem中
require 'grape'
require 'uri'
require 'yaml'
require 'erb'
require 'redis'
require 'hiredis'
require 'redis-objects'
require 'redis-activesupport'

module GGA 
  class << self 
    # The Configuration instance used to configure the GGA environment
    def root 
      File.expand_path(File.dirname(__FILE__) + '/..')
    end 

    def initialize!
      # 初始化加载路径  
      %w[apis lib models].each do |folder|
        # $LOAD_PATH为goliath的load-path
        $:.unshift(File.expand_path(root + "/app/#{folder}")) 
      end
      $:.unshift(File.expand_path(File.dirname(__FILE__)))

      # 加载初始化文件
      Dir[root + "/config/initializers/*.rb"].each {|init| require init }

      # 加载程序主文件
      require root + "/app/apis/api"
    end 

    def logger 
      @@logger ||= nil 
    end 

    def logger=(logger)
      @@logger = logger
    end 

    def sys_log(&block)
      if block_given?
        Goliath::Request.log_block = block
      end 
    end 
  end 

  # 初始化程序
  initialize!
end 

