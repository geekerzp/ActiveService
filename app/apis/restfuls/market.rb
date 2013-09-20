#encoding:utf-8
module Restfuls

class Market < Grape::API
  format :json
  helpers MarketHelper
  resource 'market' do
    desc '收徒'
    params do
      requires :session_key, type: String, desc: "user's session_key"
      requires :type, type: String, desc:'弟子类型'
    end
    get '/obtain_disciple' do
      obtain_disciple
    end
    post '/obtain_disciple' do
      obtain_disciple
    end

    desc '购买道具'
    params do
      requires :session_key, type: String, desc: "user's session_key"
      requires :name, type: String, desc:"道具名称"
    end
    get '/buy_goods' do
      buy_goods
    end
    post '/buy_goods' do
      buy_goods
    end

    desc '获取我的礼包列表'
    params do
      requires :session_key, type: String, desc: "user's session_key"
    end
    get '/get_my_gift_bags' do
      get_my_gift_bags
    end
    post '/get_my_gift_bags' do
      get_my_gift_bags
    end

    desc '购买礼包'
    params do
      requires :session_key, type: String, desc: "user's session_key"
      requires :type, type: String, desc: "礼包类型"
    end
    get '/buy_gift_bag' do
      buy_gift_bag
    end
    post '/buy_gift_bag' do
      buy_gift_bag
    end

    desc '打开礼包'
    params do
      requires :session_key, type: String, desc: "user's session_key"
      requires :type, type: String, desc: "礼包类型"
    end
    get '/open_gift_bag' do
      open_gift_bag
    end
    post '/open_gift_bag' do
      open_gift_bag
    end

    desc '获取收徒记录接口'
    params do
      requires :session_key, type: String, desc: "user's session_key"
    end
    get '/get_obtain_disciple_recorders' do
      get_obtain_disciple_recorders
    end
    post '/get_obtain_disciple_recorders' do
      get_obtain_disciple_recorders
    end

  end
  end
end