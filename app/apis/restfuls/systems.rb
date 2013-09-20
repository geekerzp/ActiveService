#encoding:utf-8
module Restfuls
  class Systems < Grape::API
    format :json

    helpers SystemHelper
    resource 'system' do
      desc "获取系统补偿信息列表"
      params do
        requires :session_key, type: String, desc:"user's session_key"
      end
      get '/get_system_reward_messages' do
        get_system_reward_messages
      end
      post '/get_system_reward_messages' do
        get_system_reward_messages
      end

      desc "领取系统补偿"
      params do
        requires :session_key, type: String, desc:"user's session_key"
        requires :system_reward_id, type: Integer, desc:"系统奖励的id"
      end
      get '/get_system_reward' do
        get_system_reward
      end
      post '/get_system_reward' do
        get_system_reward
      end

      desc "获取用户系统信息列表" 
      params do 
        requires :session_key, type: String, desc: "user's session_key'"
      end 
      get '/get_system_messages' do 
        authenticate!                       
        get_system_meesages
      end 
      post '/get_system_messages' do 
        authenticate!
        get_system_meesages
      end 
    end
  end
end
