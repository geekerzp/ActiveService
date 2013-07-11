class ContinuousLoginReward < ActiveRecord::Base
  attr_accessible :continuous_login_time, :receive_or_not, :reward_1_type, :reward_2_type, :reward_3_type, :user_id
  attr_accessible :reward_1_id, :reward_2_id, :reward_3_id

  RECEIVED = 1
  NOT_RECEIVED = 0

  #
  # 将continuous_login_reward的信息转化为字典形式
  #
  def to_dictionary
    re = {}
    re[:continuous_login_time] = self.continuous_login_time
    re[:receive_or_not] = self.receive_or_not
    re[:reward_1_id] = URI.encode(self.reward_1_id || '')
    re[:reward_2_id] = URI.encode(self.reward_2_id || '')
    re[:reward_3_id] = URI.encode(self.reward_3_id || '')
    re[:reward_1_type] = self.reward_1_type
    re[:reward_2_type] = self.reward_2_type
    re[:reward_3_type] = self.reward_3_type
    re
  end

end
