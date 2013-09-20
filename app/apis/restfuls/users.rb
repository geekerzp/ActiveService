#encoding: utf-8
module Restfuls
  class Users < Grape::API
    format :json

    helpers UserHelper

    resource 'user' do
      desc 'users to login用户登陆'
      params do
        requires :username, type: String, desc: "user's login name"
        requires :password, type: String, desc: "user's password"
      end
      get '/login' do
          login
      end
      post '/login' do
        login
      end

      desc 'register a users'
      params do
        requires :username, type: String, desc: "user's login name"
        requires :password, type: String, desc: "user's password"
      end
      get '/register' do
        register
      end
      post '/register' do
        register
      end

      desc 'get login reward'
      params do
        requires :session_key, type: String, desc: "user's session_key"
      end
      get '/receive_login_reward' do
        receive_login_reward
      end
      post '/receive_login_reward' do
        receive_login_reward
      end

      desc 'get user information'
      params do
        requires :session_key, type: String, desc: "user's session_key"
      end
      get '/get_user_info' do
        get_user_info
      end
      post '/get_user_info' do
        get_user_info
      end

      desc 'update user information'
      params do
        requires :name, type: String, desc: "用户门派名称"
        requires :session_key, type: String, desc: "user's session_key"
      end
      get '/update_user_info' do
        update_user_info
      end
      post '/update_user_info' do
        update_user_info
      end

      desc '修改用户门派'
      params do
        requires :session_key, type: String, desc:"user's session_key"
        requires :zhangmen_name, type: String, desc:"用户修改后的门派名"
      end
      get '/update_zhangmen_name' do
        update_zhangmen_name
      end
      post '/update_zhangmen_name' do
        update_zhangmen_name
      end
      desc '更新用户元宝数'
      params do
        requires :session_key, type: String, desc:"user's session_key"
        requires :gold, type: String, desc:"用户元宝数"
      end
      get '/update_gold' do
        update_gold
      end
      post '/update_gold' do
        update_gold
      end

      desc '更新用户物品'
      params do
        requires :session_key, type: String, desc:"user's session_key"
        requires :goods, type: Array, desc:"用户的物品信息"
      end
      get '/update_goods' do
        update_goods
      end
      post '/update_goods' do
        update_goods
      end

      desc '获取随机未使用的掌门名称'
      params do
        requires :session_key, type: String, desc:"user's session_key"
      end
      get '/get_random_zhangmen_name' do
        get_random_zhangmen_name
      end
      post '/get_random_zhangmen_name' do
        get_random_zhangmen_name
      end

      desc '设置新手指引步骤数'
      params do
        requires :session_key, type: String, desc:"user's session_key"
        requires :direction_step, type: Integer, desc:"新手指引步骤数"
      end
      get '/set_direction_step' do
        set_direction_step
      end
      post '/set_direction_step' do
        set_direction_step
      end

      desc '获取用户的战斗信息'
      params do
        requires :session_key, type: String, desc:"user's session_key"
      end
      get '/get_fight_messages' do
        get_fight_messages
      end
      post '/get_fight_messages' do
        get_fight_messages
      end

      desc "获取用户全部信息"
      get '/get_all_messages' do
        get_all_messages
      end
      post '/get_all_messages' do
        get_all_messages
      end

      desc '搜索用户'
      params do
        requires :session_key, type: String, desc:"user's session_key"
        requires :search_word, type: String, desc:"搜索关键字"
      end
      get '/search' do
        search
      end
      post '/search' do
        search
      end

      desc '更新冲级奖励'
      params do
        requires :session_key, type: String, desc:"user's session_key"
        requires :upgrade_3_reward, type: Integer, desc:"升到3级奖励是否领取"
        requires :upgrade_5_reward, type: Integer, desc:"升到5级奖励是否领取"
        requires :upgrade_10_reward, type: Integer, desc:"升到10级奖励是否领取"
        requires :upgrade_15_reward, type: Integer, desc:"升到15级奖励是否领取"
      end
      get '/update_upgrade_reward' do
        update_upgrade_reward
      end
      post '/update_upgrade_reward' do
        update_upgrade_reward
      end

      desc "花费元宝增加体力"
      params do
        requires :session_key, type: String, desc: "user's session_key"
        requires :gold, type: String, desc:"用户剩余的元宝"
        requires :power, type: String, desc:"用户增加后的总体力"
      end
      get '/add_power_by_gold' do
        add_power_by_gold
      end
      post '/add_power_by_gold' do
        add_power_by_gold
      end

      desc "花费元宝增加气力"
      params do
        requires :session_key, type: String, desc: "user's session_key"
        requires :gold, type: String, desc:"用户剩余的元宝"
        requires :sprite, type: String, desc:"用户增加后的总体力"
      end
      get '/add_sprite_by_gold' do
        add_sprite_by_gold
      end
      post '/add_sprite_by_gold' do
        add_sprite_by_gold
      end

      desc "获取用元宝购买体力的次数"
      params do
        requires :session_key, type: String, desc: "user's session_key"
      end
      get '/get_exchange_power_time' do
        get_exchange_power_time
      end
      post '/get_exchange_power_time' do
        get_exchange_power_time
      end

      desc "获取用元宝购买气力的次数"
      params do
        requires :session_key, type: String, desc: "user's session_key"
      end
      get '/get_exchange_sprite_time' do
        get_exchange_sprite_time
      end
      post '/get_exchange_sprite_time' do
        get_exchange_sprite_time
      end

      desc "获取用户体力"
      params do
        requires :session_key, type: String, desc: "user's session_key"
      end
      get '/get_power' do
        get_power
      end
      post '/get_power' do
        get_power
      end

      desc "获取用户的气力"
      params do
        requires :session_key, type: String, desc: "user's session_key"
      end
      get '/get_sprite' do
        get_sprite
      end
      post '/get_sprite' do
        get_sprite
      end

      desc "获取用户体力和气力回复的信息"
      params do
        requires :session_key, type: String, desc: "user's session_key"
      end
      get '/get_power_and_sprite_time' do
        get_power_and_sprite_time
      end
      post '/get_power_and_sprite_time' do
        get_power_and_sprite_time
      end

      desc "充值完成后获取用户的元宝、银币、装备、物品、累计充值金额"
      params do
          requires :session_key, type: String, desc: "user's session_key"
      end
      get '/get_info_after_recharge' do
        get_info_after_recharge
      end
      post '/get_info_after_recharge' do
        get_info_after_recharge
      end

    end 
  end 
end 
