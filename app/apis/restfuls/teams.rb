#encoding:utf-8
module Restfuls
  class Teams < Grape::API
    format :json

    helpers TeamHelper
    resource 'team' do
      desc '更新阵容'
      params do
        requires :session_key, type: String, desc: "user's session_key"
        requires :team, type: Array, desc: "用户阵容列表"
      end
      get '/update_team' do
        update_team
      end
      post '/update_team' do
        update_team
      end

      desc '获取用户阵容'
      params do
        requires :session_key, type: String, desc: "user's session_key"
      end
      get '/get_team' do
        get_team
      end
      post '/get_team' do
        get_team
      end
    end
  end
end