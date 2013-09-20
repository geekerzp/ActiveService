#encoding: utf-8
module Restfuls
	class Jianghus < Grape::API
		format :json

		helpers JianghuHelper

		resource 'jianghu' do
			desc "获取江湖记录接口"
			params do
				requires :session_key, type: String, desc: "会话key"
			end
			get '/get_jianghu_recorders' do
				get_jianghu_recorders
      end
      post '/get_jianghu_recorders' do
        get_jianghu_recorders
      end

			desc "更新江湖记录接口"
			params do
				requires :session_key, type: String, desc: "会话key"
				requires :scene_id, type: Integer, desc: "场景id"
				requires :item_id, type: Integer, desc: "条目id"
				requires :star, type: Integer, desc: "得到的星级"
				requires :is_finish, type: Integer, desc: "是否通过"
			end
			get '/update_recorder' do
				update_recorder
			end
      post '/update_recorder' do
        update_recorder
      end

			desc "更新江湖挑战次数和用户元宝数"
			params do
				requires :session_key, type: String, desc: "会话key"
				requires :scene_id, type: Integer, desc: "场景id"
				requires :item_id, type: Integer, desc: "条目id"
				requires :gold, type: Integer, desc: "用户元宝数"
			end
			get '/update_recorder_fight_time_and_gold' do
				update_recorder_fight_time_and_gold
			end
      post '/update_recorder_fight_time_and_gold' do
        update_recorder_fight_time_and_gold
      end

			desc "添加叫花鸡奖励记录"
			params do
				requires :session_key, type: String, desc: "会话key"
				requires :scene_id, type: String, desc: "场景id"
			end
			get '/add_jianghu_reward_recorder' do
				add_jianghu_reward_recorder
      end
      post '/add_jianghu_reward_recorder' do
        add_jianghu_reward_recorder
      end
		end
	end
end