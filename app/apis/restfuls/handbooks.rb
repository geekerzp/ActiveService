#encoding: utf-8
module Restfuls
	class Handbooks < Grape::API
		format :json

		helpers HandbookHelper

		resource 'handbook' do
			desc '获取图鉴接口'
			params do
				requires :session_key,type: String,desc: '会话key'
			end
			get '/get_handbook' do
				get_handbook
      end
      post '/get_handbook' do
        get_handbook
      end

			desc '设置图鉴接口'
			params do
				requires :session_key,type: String,desc: '会话key'
				requires :disciples,type: Array,desc: '弟子数组'
				requires :equipment,type: Array,desc: '装备数组'
				requires :gongfu,type: Array,desc: '功夫数组'
			end
			get '/set_handbook' do
				set_handbook
      end
      post '/set_handbook' do
        set_handbook
      end

		end
	end
end