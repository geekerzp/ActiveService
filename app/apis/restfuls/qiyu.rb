# vi: set fileencoding=utf-8 :
module Restfuls
  class Qiyu < Grape::API
    format :json

    helpers QiyuHelper
    resource "qiyu" do
      desc "获取吃叫花鸡详情"
      params do
        requires :session_key, type: String, desc:"user's session_key"
      end
      get '/get_jiaohuaji_detail' do
        get_jiaohuaji_detail
      end
      post '/get_jiaohuaji_detail' do
        get_jiaohuaji_detail
      end

      desc "吃叫花鸡"
      params do
        requires :session_key, type: String, desc:"user's session_key"
        requires :type, type: Integer,desc:"1=>中午,2=>下午"
      end
      get '/eat_jiaohuaji' do
        eat_jiaohuaji
      end
      post '/eat_jiaohuaji' do
        eat_jiaohuaji
      end

      desc '获取当前的参拜记录'
      params do
        requires :session_key, type: String, desc:"user's session_key"          
      end
      get '/get_canbai_recorders' do
        get_canbai_recorders
      end
      post '/get_canbai_recorders' do
        get_canbai_recorders
      end

      desc'参拜接口'
      params do
        requires :session_key, type: String, desc:"user's session_key"
      end
      get '/canbai' do
        canbai
      end
      post '/canbai' do
        canbai
      end
    end
  end
end
