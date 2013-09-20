#encoding:utf-8
module Restfuls
  class Recharges < Grape::API
    format :json

    helpers RechargeHelper
    resource 'recharge' do
      desc "获取订单号接口"
      params do
        requires :session_key, type: String, desc:"user's session_key"
      end
      get '/get_order_number' do
        get_order_number
      end
      post '/get_order_number' do
        get_order_number
      end

      desc "获取订单充值状态接口"
      params do
        requires :session_key, type: String, desc:"user's session_key"
        requires :oid, type: String, desc:"用户订单号"
        requires :status, type: String, desc:"订单状态"
      end
      get '/post_recharge_status' do
        post_recharge_status
      end
      post '/post_recharge_status' do
        post_recharge_status
      end

      desc "充值订单处理接口用于和91服务器对接"
      params do
        requires :AppId
        requires :Act
        requires :ProductName
        requires :ConsumeStreamId
        requires :CooOrderSerial
        requires :Uin
        requires :GoodsId
        requires :GoodsInfo
        requires :GoodsCount
        requires :OriginalMoney
        requires :OrderMoney
        requires :Note
        requires :PayStatus
        requires :CreateTime
        requires :Sign
      end
      get '/recharge_process' do
        recharge_process
      end
      post '/recharge_process' do
        recharge_process
      end
    end
  end
end