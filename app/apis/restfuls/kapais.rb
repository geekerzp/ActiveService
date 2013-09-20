#encoding: utf-8
module Restfuls
	class Kapais < Grape::API
		format :json

		helpers KapaiHelper

		resource 'kapai' do
			desc "更新弟子信息"
			params do
				requires :session_key, type: String, desc: "会话key"
        requires :disciples, type: Array, desc:"用户弟子信息"
			end
			get '/update_disciples' do
				update_disciples
			end
      post '/update_disciples' do
        update_disciples
      end

			desc "更新装备信息"
			params do
				requires :session_key, type: String, desc: "会话key"
        requires :equipments, type: Array, desc:"用户装备信息"
			end
			get '/update_equipments' do
				update_equipments
			end
      post '/update_equipments' do
        update_equipments
      end

      desc "更新武功信息"
			params do
				requires :session_key, type: String, desc: "会话key"
        requires :gongfus, type: Array, desc: "用户武功信息"
			end
			get '/update_gongfus' do
				update_gongfus
			end
      post '/update_gongfus' do
        update_gongfus
      end

			desc "更新掌门诀信息"
			params do
				requires :session_key, type: String, desc: "会话key"
        requires :zhangmenjues, type: Array, desc:"用户掌门决信息"
			end
			get '/update_zhangmenjues' do
				update_zhangmenjues
			end
      post '/update_zhangmenjues' do
        update_zhangmenjues
      end

      desc "更新魂魄接口"
			params do
				requires :session_key, type: String, desc: "会话key"
        requires :souls,       type: Array,  desc:"用户魂魄信息"
			end
			get '/update_souls' do
				update_souls
			end
      post '/update_souls' do
        update_souls
      end

      desc "创建一个武功接口"
			params do
				requires :session_key, type: String, desc: "会话key"
				requires :type, type: String, desc: "武功类型"
			end
			get '/create_gongfu' do
				create_gongfu
			end
      post '/create_gongfu' do
        create_gongfu
      end

			desc "创建一个装备接口"
			params do
				requires :session_key, type: String, desc: "会话key"
				requires :type, type: String, desc: "装备类型"
			end
			get '/create_equipment' do
				create_equipment
			end
      post '/create_equipment' do
        create_equipment
      end

			desc "创建一个弟子接口"
			params do
				requires :session_key, type: String, desc: "会话key"
				requires :type, type: String, desc: "弟子类型"
			end
			get '/create_disciple' do
				create_disciple
      end
      post '/create_disciple' do
        create_disciple
      end
		end
	end
end