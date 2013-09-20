# vi: set fileencoding=utf-8 :
class SendMessage < ActiveRecord::Base 
  # 是从管理员发送还是用户发送
  FROM_ADMIN = 0
  FROM_USER  = 1

  # 是否接收成功
  RECEIVE_SUCCESS = 0
  RECEIVE_FAIL    = 0

  validates :message, presence: true 
  validates :m_type, inclusion: {in: [FROM_ADMIN, FROM_USER] }
  validates :sender_id, :receiver_id, presence: true
end 
