class RechargeController < ApplicationController
  def get_order_number
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    orderNumber = ("%04d" % rand(1000)) << DateTime.parse(Time.now.to_s()).strftime('%Y%m%d%H%M%S')  << "%04d" % (user.id.hash % 10000).abs
    order = Order.new
    order.create_blank_order(user.id,orderNumber,0)
    render_result(ResultCode::OK,{ordernumber: orderNumber})

    return


  end

  def get_recharge_status
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    oid = get_params(params,:oid)
    if oid.nil?
      render_result(ResultCode::ERROR,{err_msg:"oid is null"})
      return
    end
    order = Order.find_by_oid(oid)

    if(order.nil?)
      render_result(ResultCode::ERROR,{err_msg:"invalid oid"})
    end

      case order.status
        when 0
          render_result(ResultCode::ERROR,{err_msg: "order is handling"})
          return
        when 1
          render_result(ResultCode::OK,{err_msg:"recharge finished"})
          return
        when 2
          render_result(ResultCode::ERROR,{err_msg: "recharge failed"})
          return
        else
          render_result(ResultCode::ERROR,{err_msg: "invalid order status"})
          return
      end

    return
  end
end