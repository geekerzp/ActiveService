# vi: set fileencoding=utf-8 :
require 'second_level_cache/second_level_cache'

class CanbaiRecorder < ActiveRecord::Base
  acts_as_cached(version: 1, expires_in: 1.week)  # 开启二级缓存

  attr_accessible :canbai_at, :user_id
end
