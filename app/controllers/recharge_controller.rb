# vi: set fileencoding=utf-8 :
class RechargeController < ApplicationController
  #
  # 获取订单号接口
  #
  def get_order_number
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    order_number = ("%04d" % rand(1000)) << DateTime.parse(Time.now.to_s()).strftime('%Y%m%d%H%M%S')  << "%04d" % (user.id.hash % 10000).abs
    order = Order.new
    if order.create_blank_order(user.id,order_number,0)
      render_result(ResultCode::OK,{ordernumber: order_number})
    else
      render_result(ResultCode::ERROR,{err_msg: "获取订单号失败"})
    end
  end

  #
  # 获取订单充值状态接口
  #
  def post_recharge_status
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    oid = get_params(params, :oid)
    status = get_params(params, :status)
    if oid.empty? or status.empty?
      render_result(ResultCode::ERROR, {err_msg:"参数错误"})
      return
    end

    order = Order.find_by_oid(oid)
    if !order.nil? and status=='0' and order.status==0
      order.destroy
      render_result(ResultCode::OK, {})
      return 
    end 

    render_result(ResultCode::ERROR, {err_msg: "删除空订单失败"})
  end

  #
  # 充值订单处理接口
  # 用于和91服务器对接
  #
  def recharge_process
    # 存放结果哈希表
    result = {}

    # 验证get参数
    if params.nil? || params[:AppId].nil? || params[:Act].nil? || params[:ProductName].nil? || params[:ConsumeStreamId].nil? \
      || params[:CooOrderSerial].nil? || params[:Uin].nil? || params[:GoodsId].nil? || params[:GoodsInfo].nil? || params[:GoodsCount].nil? \
      || params[:OriginalMoney].nil? || params[:OrderMoney].nil? || params[:Note].nil? || params[:PayStatus].nil? || params[:CreateTime].nil? \
      || params[:Sign].nil?
      logger.error('接收失败')
      result[:ErrorCode] = '0' # 注意这里的错误码一定要是字符串格式
      result[:ErrorDesc] = URI.encode('接收失败')
      render(:json => result)
      return
    end

    app_id            = params[:AppId]
    act               = params[:Act]
    product_name      = params[:ProductName]
    consume_stream_id = params[:ConsumeStreamId]
    coo_order_serial  = params[:CooOrderSerial]
    uin               = params[:Uin]
    goods_id          = params[:GoodsId]
    goods_info        = params[:GoodsInfo]
    goods_count       = params[:GoodsCount]
    original_money    = params[:OriginalMoney]
    order_money       = params[:OrderMoney]
    note              = params[:Note]
    pay_status        = params[:PayStatus]
    create_time       = params[:CreateTime]
    sign              = params[:Sign]

    # 因为是接收验证支付购买结果的操作，所以如果此值不为1时就是无效操作
    unless act == '1'
      logger.error('Act无效')
      result[:ErrorCode] = "3" # 注意这里的错误码一定要是字符串格式
      result[:ErrorDesc] = URI.encode('Act无效')
      render(:json => result)
      return
    end

    # 如果传过来的应用ID开发者自己的应用ID不同，那说明这个应用ID无效
    unless APPID == app_id
      logger.error('AppId无效')
      result[:ErrorCode] = "2"
      result[:ErrorDesc] = URI.encode('AppId无效')
      render(:json => result)
      return
    end

    # 91服务器付款失败
    unless pay_status == '1'
      logger.error('91服务器付款失败')
      result[:ErrorCode] = '7'
      result[:ErrorDesc] = '91服务器付款失败'
      render(:json => result)
      return
    end

    # 拼接加密数据，生成签名
    sign_check = ''
    sign_check << APPID << act << product_name << consume_stream_id << coo_order_serial \
      << uin << goods_id << goods_info << goods_count << original_money << order_money \
      << note << pay_status << create_time << APPKEY
    sign_check = Digest::MD5.hexdigest(sign_check)

    # 当本地生成的加密sign跟传过来的sign一样时说明数据没问题
    if sign_check == sign
      # 处理逻辑

      # 订单不存在
      unless Order.exists?(:oid => coo_order_serial)
        logger.error('订单信息不存在')
        result[:ErrorCode] = '11'
        result[:ErrorDesc] = URI.encode('订单信息不存在')
        render(:json => result)
        return
      end

      # 处理订单 注意订单已经被处理
      order = Order.find_by_oid(coo_order_serial)
      # 订单未被成功处理
      if order.status == 0
        order.csid= URI.decode(consume_stream_id)
        order.gid= URI.decode(goods_id)
        order.ginfo= URI.decode(goods_info)
        order.gcount= goods_count.to_i
        order.ogmoney= original_money.to_f
        order.omoney= order_money.to_f
        order.o_type = '91'   # 订单类型为91平台


        # 订单处理
        if order.process
          logger.error('订单成功处理')
          result[:ErrorCode] = '1'
          result[:ErrorDesc] = URI.encode('成功')
          render(:json => result)
          return
        else
          # 订单处理失败
          logger.error('订单处理失败')
          result[:ErrorCode] = '6'
          result[:ErrorDesc] = URI.encode('订单处理失败')
          render(:json => result)
          return
        end
      else
        # 订单处理成功
        logger.error('订单重复处理')
        result[:ErrorCode] = '1'
        result[:ErrorDesc] = URI.encode('成功')
        render(:json => result)
        return
      end
    else
      # 签名无效
      logger.error('Sign无效')
      result[:ErrorCode] = '5'
      result[:ErrorDesc] = URI.encode('Sign无效')
      render(:json => result)
    end
  end
end
