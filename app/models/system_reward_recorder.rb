require 'message_type'
class SystemRewardRecorder < ActiveRecord::Base
  attr_accessible :receive_or_not, :reward_type, :system_message, :user_id

  RECEIVED = 1
  NOT_RECEIVED = 0

  #
  # 获取系统信息列表
  #
  def self.get_system_messages(user_id)
    messages = SystemRewardRecorder.where('user_id = ?',user_id).order('created_at desc').limit(10)
    message_array = []
    messages.each do |message|
      message_array << message.to_dictionary
    end
    message_array
  end

  #
  # 将信息转化为字典形式
  #
  def to_dictionary
    re = {}
    re[:message_type] = MessageType::SYSTEM_MESSAGE # 系统消息
    re[:system_reward_id] = self.id
    re[:reward_type] = URI.encode(self.reward_type || '')
    re[:receive_or_not] = self.receive_or_not
    if self.created_at.nil?
      re[:time] = URI.encode('')
    else
      re[:time] = URI.encode(self.created_at.strftime('%Y-%m-%d %H:%M:%S') || '')
    end
    re[:message] = URI.encode(self.system_message || '')
    re
  end

end
