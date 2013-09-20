# vi: set fileencoding=utf-8 :
require 'second_level_cache/second_level_cache'

class Handbook < ActiveRecord::Base
  acts_as_cached(version: 1, expires_in: 1.week)  # 开启二级缓存

  attr_accessible :exist_type, :object_id, :object_type, :user_id

  belongs_to :user

  #
  # 获取对应类型的图鉴
  #
  # @param [integer] user_id 用户id
  # @param [integer] type 图鉴类型
  # @return [Array] 图鉴数组
  def self.get_handbook_by_type(user_id, type)
    handbooks = Handbook.where('user_id = ? AND object_type = ?', user_id, type)
    handbook_array = []
    handbooks.each() do |handbook|
      handbook_array << handbook.to_dictionary()
    end
    return handbook_array
  end


  #
  # 将handbook信息转化为字典形式
  #
  def to_dictionary()
    re = {}
    re[:id] = URI.encode(self.object_id || '')
    re[:type] = self.exist_type
    re
  end

  #
  # 添加对应的handbook信息
  #
  # @param [integer] user_id 用户id
  # @param [integer] object_type 对象类型
  # @param [integer] object_id 图鉴类型
  # @param [integer] exist_type 图鉴类型
  # @return [boolean] flag
  #
  def self.add(user_id, object_type, object_id, exist_type)
    handbook = Handbook.find_by_user_id_and_object_type_and_object_id(user_id, object_type, object_id)

    if handbook.nil?
      handbook = Handbook.new
    end

    handbook.user_id = user_id
    handbook.object_type = object_type
    handbook.object_id = object_id
    handbook.exist_type = exist_type

    handbook.save
    return true
  end


end
