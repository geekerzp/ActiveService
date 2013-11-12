require 'rubygems'
require 'bundler/setup'
require 'active_support'
require 'em-synchrony/activerecord'
require 'em-synchrony/mysql2'
# rails4的ActiveRecord将attr_accessible类宏移到了Gem中
require 'protected_attributes'
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
    def root
      ::File.expand_path('../../', __FILE__)
    end

    def initialize!
      load_path

      load_init_files

      load_application
    end

    def logger
      @logger ||= nil
    end

    def logger=(logger)
      @logger = logger
    end

    def sys_log(&block)
      Goliath::Request.log_block = block if block_given?
    end

    private

    def load_path
      %w[apis lib models].each {|folder| $: << File.expand_path("./app/#{folder}", root) }
    end

    def load_init_files
      Dir[File.expand_path("./config/initializers/*.rb", root)].each {|file| require file }
    end

    def load_application
      require File.expand_path("./app/apis/application", root)
    end
  end
end

# Initialize environment
GGA.initialize!
