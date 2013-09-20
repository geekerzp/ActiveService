# vi: set fileencoding=utf-8 :
require 'second_level_cache/second_level_cache'
require 'message_type'

class Message < ActiveRecord::Base
  acts_as_cached(version: 1, expires_in: 1.week)  # 开启二级缓存

  attr_accessible :message, :receiver_id, :sender_id

  #
  # 获取留言列表
  # 一定要写好参数注释
  #
  def self.get_leave_messages(user_id)
    messages = Message.where('receiver_id = ?',user_id).order('created_at desc').limit(10)
    message_array = []
    messages.each do |message|
      user = User.find_by_id(message.sender_id)
      next if user.nil?
      message_array << message.to_dictionary
    end
    message_array
  end


  #
  # 将信息转化为字典形式
  # 注意连续赋值对其和逻辑换行
  #
  def to_dictionary
    re                = {}
    re[:message_type] = MessageType::FRIEND_MESSAGE # 好友信息
    re[:sender_id]    = self.sender_id
    user              = User.find_by_id(self.sender_id)
    re[:sender_name]  = URI.encode(user.name || '')

    if self.created_at.nil?
      re[:time] = URI.encode('')
    else
      re[:time] = URI.encode(self.created_at.strftime('%Y-%m-%d %H:%M:%S') || '')
    end

    re[:message] = URI.encode(self.message || '')
    re
  end

end
