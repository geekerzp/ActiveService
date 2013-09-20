# vi: set fileencoding=utf-8 :
class UserMessage < ActiveRecord::Base 
  # 消息类型
  BroadCast     = 0
  PointToPoint  = 1

  belongs_to :user

  validates :m_type, inclusion: { in: [BroadCast, PointToPoint] }
end 
