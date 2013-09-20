#encoding: utf-8
module Restfuls
	class Friends < Grape::API
		format :json

		helpers FriendHelper

		resource 'friend' do 
			desc '申请好友接口'
			params do
				requires :session_key,type: String,desc: '会话key'
				requires :receiver_id,type: Integer,desc: '接收者id'
			end
			get '/apply' do
				apply
			end
      post '/apply' do
        apply
      end

			desc '关注仇敌'
			params do
				requires :session_key,type: String,desc: '会话key'
				requires :receiver_id,type: Integer,desc: '接收者id'
			end
			get '/follow' do
				follow
			end
      post '/follow' do
        follow
      end

			desc '回复好友申请'
			params do
				requires :session_key,type: String,desc: '会话key'
				requires :sender_id,type: Integer,desc: '申请者id'
				requires :reply_type,type: Integer,desc: '回复类型'
			end
			get '/reply_apply' do
				reply_apply
			end
      post '/reply_apply' do
        reply_apply
      end

			desc '给好友留言'
			params do
				requires :session_key,type: String,desc: '会话key'
				requires :receiver_id,type: Integer,desc: '收到者id'
				requires :message,type: String,desc: '留言内容'
			end
			get '/leave_message' do
				leave_message
			end
      post '/leave_message' do
        leave_message
      end

			desc '获取关系用户列表接口'
			params do
				requires :session_key,type: String,desc: '会话key'
				requires :relation_type,type: Integer,desc: '关系类型'
			end
			get '/get_relation_user_list' do
				get_relation_user_list
			end
      post '/get_relation_user_list' do
        get_relation_user_list
      end

			desc '获取留言列表接口'
			params do
				requires :session_key,type: String,desc: '会话key'
			end
			get '/get_message_list' do
				get_message_list
			end
      post '/get_message_list' do
        get_message_list
      end
		end	
	end
end