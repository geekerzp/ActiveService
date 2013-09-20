#encoding: utf-8
module Restfuls
	class Lunjians < Grape::API
		format :json

		helpers LunjianHelper

		resource 'lunjian' do
			desc "获取论剑列表接口"
			params do
				requires :session_key, type: String, desc: "会话key"
			end
			get '/get_list' do
				get_list
			end
      post '/get_list' do
        get_list
      end

			desc "更新挑战结果接口"
			params do
				requires :session_key, type: String, desc: "会话key"
				requires :id, type: Integer, desc: "挑战的用户的论剑位置id"
				requires :position, type: Integer, desc: "挑战的用户的位置"
				requires :defender_id, type: Integer, desc: "防守者id"
				requires :is_win, type: Integer, desc: "是否挑战成功"
			end
			get '/update_result' do
				update_result
			end
      post '/update_result' do
        update_result
      end

			desc "刷新积分接口"
			params do
				requires :session_key, type: String, desc: "会话key"
			end
			get '/refresh_recorder' do
				refresh_recorder
			end
      post '/refresh_recorder' do
        refresh_recorder
      end

			desc "获取已获得的论剑奖励记录接口"
			params do
				requires :session_key, type: String, desc: "会话key"
			end
			get '/get_reward_recorders' do
				get_reward_recorders
			end
      post '/get_reward_recorders' do
        get_reward_recorders
      end

			desc "添加论剑奖励记录接口"
			params do
				requires :session_key, type: String, desc: "会话key"
				requires :position, type: Integer, desc: "领奖时的位置"
				requires :reward, type: Integer, desc: "奖励类型"
			end
			get '/add_reward_recorder' do
				add_reward_recorder
			end
      post '/add_reward_recorder' do
        add_reward_recorder
      end

			desc "获取用户被挑战信息接口"
			params do
				requires :session_key, type: String, desc: "会话key"
			end
			get '/get_defend_messages' do
				get_defend_messages
			end
      post '/get_defend_messages' do
        get_defend_messages
      end

		end
	end
end