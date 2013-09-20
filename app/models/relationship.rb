# vi: set fileencoding=utf-8 :
require 'second_level_cache/second_level_cache'

class Relationship < ActiveRecord::Base
  acts_as_cached(version: 1, expires_in: 1.week)  # 开启二级缓存

  attr_accessible :friend_id, :relation_type, :user_id

  # 好友关系类型
  RELATIONSHIP_FRIEND = 1
  RELATIONSHIP_ENEMY  = 2
  RELATIONSHIP_FOLLOW = 3

  #
  # 添加关系
  #
  def self.add(user_id, friend_id, relationship_type)
    if relationship_type == RELATIONSHIP_FRIEND
      relation = Relationship.find_by_user_id_and_friend_id_and_relation_type(user_id, friend_id, relationship_type)
      if relation.nil?
        # 建立双向好友关系
        relationship_1 = Relationship.new
        relationship_1.user_id = user_id
        relationship_1.friend_id = friend_id
        relationship_1.relation_type = relationship_type
        save_flag_1 = relationship_1.save

        relationship_2 = Relationship.new
        relationship_2.user_id = friend_id
        relationship_2.friend_id = user_id
        relationship_2.relation_type = relationship_type
        save_flag_2 = relationship_2.save

        save_flag_1 && save_flag_2
      else
        false
      end
    elsif relationship_type == RELATIONSHIP_ENEMY || relationship_type == RELATIONSHIP_FOLLOW
      relation = Relationship.find_by_user_id_and_friend_id_and_relation_type(user_id, friend_id, relationship_type)
      if relation.nil?
        # 建立单向仇敌关系 或者 建立单向关注关系
        relationship = Relationship.new
        relationship.user_id = user_id
        relationship.friend_id = friend_id
        relationship.relation_type = relationship_type
        relationship.save
      else
        # 保证最新战斗的仇敌在最上面
        if relationship_type == RELATIONSHIP_ENEMY
          relation.updated_at = Time.now
          relation.save
        end
      end
    else
      false
    end
  end

  #
  # 检查用户之间的关系
  #
  def self.check_relationship(user_id, receiver_id, relationship_type)
     !Relationship.find_by_user_id_and_friend_id_and_relation_type(user_id, receiver_id, relationship_type).nil?
  end


  #
  # 获取用户之间的关系
  #
  def self.get_relationship(user_id, relationship_type)
    relationships = Relationship.where('user_id = ? AND relation_type = ?',user_id, relationship_type).\
      order('created_at desc').limit(30)
    relation_array = []
    relationships.each do |relationship|
      relation_array << relationship.to_dictionary
    end
    relation_array
  end


  #
  # 将信息转化为字典形式
  #
  def to_dictionary
    re = {}
    re[:user_id] = self.friend_id
    user = User.find_by_id(self.friend_id)
    re[:name] = URI.encode(user.name || '')
    re[:level] = user.level
    re
  end

end
