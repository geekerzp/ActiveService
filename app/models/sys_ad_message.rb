# vi: set fileencoding=utf-8 :
class SysAdMessage < ActiveRecord::Base 

  # 是管理员添加还是客户端推送
  FROM_ADMIN  = 0
  FROM_CLIENT = 1

  validates :message, presence: true 
  validates :m_type, inclusion: { in: [FROM_ADMIN, FROM_CLIENT] }
end 
