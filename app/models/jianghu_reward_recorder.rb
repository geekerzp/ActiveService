# vi: set fileencoding=utf-8 :
require 'second_level_cache/second_level_cache'

class JianghuRewardRecorder < ActiveRecord::Base
  acts_as_cached(version: 1, expires_in: 1.week)  # 开启二级缓存

  attr_accessible :reward, :scene_id, :user_id

  belongs_to :user

  validates :scene_id, :user_id, :presence => true, :numericality => {:greater_than => 0, :only_integer => true}
end
