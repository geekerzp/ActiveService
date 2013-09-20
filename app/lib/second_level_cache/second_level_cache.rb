# vi: set fileencoding=utf-8 :
require File.expand_path(File.dirname(__FILE__)) + '/relate_path'
require 'active_support/all'
require 'second_level_cache/config'
require 'second_level_cache/record_marshal'
require 'digest/md5'

module SecondLevelCache
  def self.configure
    block_given? ? yield(Config) : Config
  end

  class << self
    delegate :logger, :cache_store, :cache_key_prefix, :to => Config
  end

  module Mixin
    extend ActiveSupport::Concern

    #
    # ActiveRecord::Base增加的类方法
    #
    module ClassMethods
      attr_reader :second_level_cache_options

      # 开启second_level_cache的类宏
      def acts_as_cached(options = {})
        @second_level_cache_enabled = true
        @second_level_cache_options = options
        @second_level_cache_options[:expires_in] ||= 1.week
        @second_level_cache_options[:version] ||= 0
        # 增加ActiveRecord::FinderMethods的patch，在查找方法上增加缓存
        relation.class.send :include, SecondLevelCache::ActiveRecord::FinderMethods
      end

      # 判断是否开启二级缓存
      def second_level_cache_enabled?
        !!@second_level_cache_enabled   # !!可将对象转换为bool
      end
      
      # 关联一个block，可以在block中暂时关闭二级缓存
      def without_second_level_cache
        old, @second_level_cache_enabled = @second_level_cache_enabled, false

        yield if block_given?
      ensure
        @second_level_cache_enabled = old
      end

      def cache_store
        Config.cache_store
      end

      def logger
        Config.logger
      end

      def cache_key_prefix
        Config.cache_key_prefix
      end

      def cache_version
        second_level_cache_options[:version]
      end

      # 根据id生成缓存key
      def second_level_cache_key(id)
        "#{cache_key_prefix}/#{name.downcase}/#{id}/#{cache_version}"
      end

      # 根据id读取缓存
      def read_second_level_cache(id)
        RecordMarshal.load(SecondLevelCache.cache_store.read(second_level_cache_key(id))) if self.second_level_cache_enabled?
      end

      # 根据id使缓存过期
      def expire_second_level_cache(id)
        SecondLevelCache.cache_store.delete(second_level_cache_key(id)) if self.second_level_cache_enabled?
      end
      
=begin
      #
      # 根据查询条件将对象读出缓存 
      #
      # 如果查询条件对应的缓存不存在，
      # 则从数据库读入缓存
      #
      # @param attrs  为相关查询条件
      # @param block  为相关缓存不存在时，进行数据库操作的代码块
      #
      # @return       如果缓存存在，返回缓存的对象
      #               如果缓存不存在，执行关联代码块，同时返回值
      #               如果Redis服务器异常，直接返回代码块执行结果或nil
      # 
      def cache_read(attrs = {}, &block)
        attrs_key = generate_attrs_key(attrs)
        index = SecondLevelCache.cache_store.read attrs_key
        
        # 索引缓存不存在
        if index.nil?
          # 如果缓存索引不存在，且没有关联代码块，
          # 则返回nil
          return nil unless block_given?

          # 如果缓存索引不存在，且关联代码块，
          # 则执行代码块，将结果集对象存如缓存，返回结果集对象
          result = yield 
          return nil if result.nil?
          if result.respond_to?(:each)              # result为对象数组
            result.each do |obj|
              obj.write_second_level_cache
              add_obj_to_index(attrs_key, obj.id)
            end 
          else                                      # result为单个对象
            result.write_second_level_cache
            add_obj_to_index(attrs_key, result.id)
          end 
          return result
        end 

        # 索引缓存存在
        result = []
        index.each {|id| result << self.read_second_level_cache(id) } 

        # 如果缓存的对象中包含nil，则说明缓存的相应对象已经失效，
        # 需要使索引失效，并重新执行cache_read
        if result.include? nil
          SecondLevelCache.cache_store.delete attrs_key
          cache_read(attrs, &block)
        end 

        result = result[0] if result.count == 1   # 如果只有一个元素，则返回单个对象
        result
      rescue  => e
        logger.error "###### SecondLevelCache server connection error! #{e.message}"
        return block.call if block_given?
        nil
      end
=end

=begin
      # 
      # 根据查询条件过期缓存对象
      #
      # 当查询的结果集中插入新的元素后，需要手动使缓存过期
      #
      # @param attrs  为相关查询条件 
      #
      # @return       如果索引缓存不存在，返回nil
      #               如果操作成功，返回true
      #               如果Redis服务器异常，直接返回true
      #
      def expire_cache_by_attrs(attrs = {})
        attrs_key = generate_attrs_key(attrs)
        index = SecondLevelCache.cache_store.read attrs_key
        
        # 如果索引缓存不存在，则返回nil
        return nil if index.nil?

        index.each {|id| self.expire_second_level_cache(id) }
        SecondLevelCache.cache_store.delete(attrs_key) if self.second_level_cache_enabled?
        true
      rescue => e 
        logger.error "###### SecondLevelCache server connection error! #{e.message}"
        true
      end 
=end
      private 
=begin
      # 生成某个类查询条件到缓存对象索引的缓存的键
      def generate_attrs_key(attrs = {})
        result = []
        attrs.each {|i, v| result << [i, v].join('=') }
        result.unshift(self.to_s)
        result.join(',')
        #Digest::MD5.hexdigest(result.join(','))
      end 

      # 建立某个查询条件的键到对应查询结果对象集的键的索引
      def add_obj_to_index(attrs_key, id)
        index = SecondLevelCache.cache_store.read attrs_key
        index ||= []
        index << id
        SecondLevelCache.cache_store.write(attrs_key, index,
                                          :expires_in => self.second_level_cache_options[:expires_in])
      end
=end 
    end

    #
    # ActiveRecord::Base增加的实例方法 
   
    
    # 生成缓存key
    def second_level_cache_key
      self.class.second_level_cache_key(id)
    end

    # 使对象自身缓存过期
    def expire_second_level_cache
      SecondLevelCache.cache_store.delete(second_level_cache_key) if self.class.second_level_cache_enabled?
    end

    # 将对象自身写入缓存
    def write_second_level_cache
      if self.class.second_level_cache_enabled?
        SecondLevelCache.cache_store.write(second_level_cache_key, 
                                           RecordMarshal.dump(self), 
                                           :expires_in => self.class.second_level_cache_options[:expires_in])
      end
    end

    alias update_second_level_cache write_second_level_cache
  end
end

require 'second_level_cache/active_record' if defined?(ActiveRecord)
