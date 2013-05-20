class JianghuRewardRecorder < ActiveRecord::Base
  attr_accessible :reward, :scene_id, :user_id

  belongs_to :user

  validates :scene_id, :user_id, :presence => true, :numericality => {:greater_than => 0, :only_integer => true}
end
