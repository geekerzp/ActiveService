#
# goliath websocket服务器启动文件（程序初始化）
#

# 加载核心模块
require './core/gga'

# 加载Goliath
require 'goliath'
require 'goliath/websocket'

require 'json'

class ApplicationApi < Goliath::WebSocket
  @@individual_channels = {}

  def on_open(env)
    env.logger.info("WS OPEN")

    # 建立channel
    @@individual_channels[env.object_id] = { :channel => EM::Channel.new, :queue => EM::Queue.new }
    @@individual_channels[env.object_id][:subscription] = 
      @@individual_channels[env.object_id][:channel].subscribe {|m| env.stream_send(m) }
    # subscribe channel
    env[:subscription] = env.channel.subscribe { |m| env.stream_send(m) }

    chat_messages = ChatMessage.today_chat_messages(ChatMessage::ALL_USERS) 

    res = {}
    res['chat_messages'] = []
    chat_messages.each {|chat| res['chat_messages'] << chat.inspect }
    @@individual_channels[env.object_id][:channel] << res.to_json
  end

  def on_message(env, msg)
    # 注意：需要一个纤程来封装
    Fiber.new {
      json_msg = JSON.parse(msg)
      chat = ChatMessage.create_by_session(json_msg['session_key'], json_msg['message'], ChatMessage::ALL_USERS,)
      if chat.nil?   
        # 如果创建聊天信息失败，关闭channel
        on_close(env)
        env.logger.info("WS MESSAGE: session_key valid")
      elsif
        res                  = {}
        res['chat_messages'] = []
        res['chat_messages'] << chat.inspect
        env.channel << res.to_json
        env.logger.info("WS MESSAGE: #{res.to_json}")
      end 
    }.resume
  end

  def on_close(env)
    # 关闭独立频道
    unless @@individual_channels[env.object_id].nil?
      @@individual_channels[env.object_id][:channel].unsubscribe(@@individual_channels[env.object_id][:subscription]) 
    end 
    # 关闭公共频道
    env.channel.unsubscribe(env[:subscription]) if @@individual_channels.empty? 
    env.logger.info("WS CLOSED")
  end

  def on_error(env, error)
    env.logger.error error
  end

  def response(env)
    if env['REQUEST_PATH'] == '/all_users'
      super(env)
    elsif env['REQUEST_PATH'] == '/lian_meng'
      super(env)
    else
      [404, {}, 'socket path error']
    end
  end
end
