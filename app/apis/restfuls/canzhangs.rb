#encoding: utf-8
module Restfuls
	class Canzhangs < Grape::API
		#version 'v1',:using => :path
		format :json
		helpers CanzhangHelper
		resource 'canzhang'  do
			desc '获取拥有残章的用户接口列表'
			params do
				requires :session_key,type: String,desc: "会话key"
				requires :type,type: String,desc: "残章类型"
			end
			get '/get_list' do 
				get_list
			end
      post '/get_list' do
        get_list
      end

			desc '上传抢夺残章结果接口'
			params do
				requires :session_key,type: String,desc: "会话key"
				requires :type,type: String,desc: "残章类型"
				requires :user_id,type: String,desc: "被抢夺的用户id"
				requires :is_win,type: Integer,desc: "是否赢了"
			end
			get '/update_result' do
				update_result
      end
      post '/update_result' do
        update_result
      end

			desc "获取我拥有的残章列表"
			params do
				requires :session_key, type: String, desc: "会话key"
			end
			get '/get_my_canzhangs' do
				get_my_canzhangs
      end
      post '/get_my_canzhangs' do
        get_my_canzhangs
      end

			desc "更新残章接口"
			params do
				requires :session_key, type: String, desc: "会话key"
				requires :canzhangs,type: Array,desc: "残章数组"
				requires :id,type: Integer,desc: "残章记录id"
				requires :number, type: Integer,desc: "残章数量"
			end
			get '/update_canzhangs' do
				update_canzhangs
      end
      post '/update_canzhangs' do
        update_canzhangs
      end

			desc "获取用户被夺残章信息"
			params do
				requires :session_key, type: String, desc: "会话key"
			end
			get '/get_grabbed_messages' do
				get_grabbed_messages
			end
      post '/get_grabbed_messages' do
        get_grabbed_messages
      end

			desc "创建一个用户的残章"
			params do
				requires :session_key, type: String, desc: "会话key"
				requires :type, type: String, desc: "残章类型"
				requires :number, type: Integer, desc: "残章的数量"
			end
      get '/create_canzhang' do
				create_canzhang
      end
      post '/create_canzhang' do
        create_canzhang
      end
		end
	end
end
