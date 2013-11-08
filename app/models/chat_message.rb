# vi: set fileencoding=utf-8 :

# 聊天信息类
class ChatMessage < ActiveRecord::Base 
  # 聊天类型
  ALL_USERS = 1   # 全服聊天
  LIAN_MENG = 2   # 联盟聊天

  belongs_to :user

  validates :chat_type, presence: true, inclusion: { in: [ALL_USERS, LIAN_MENG] }
  validates :message, presence: true, length: { maximum: 60,  minimum: 1 }

  scope :last_n_days ->(days){ where('update < ?', days) }
  scope :type_of ->(type){ where('chat_type = ?', type) }

  class << self 
    def today_chat_messages(chat_type = ALL_USERS)
      ChatMessage.type_of(chat_type).last_n_days(1)
    end 

    # 通过session_key创建聊天信息
    def create_by_session(session_key, message, chat_type = ALL_USERS)
      user = User.find_by_session_key(session_key)
      return nil if user.nil?

      ChatMessage.create(user: user, message: message, chat_type: chat_type)
    end 
  end 

  def inspect 
    res = {}
    res[:name] = self.user.username
    res[:message] = self.message
    res
  end 
end 
