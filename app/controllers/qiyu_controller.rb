class QiyuController < ApplicationController
  #
  # 获取吃叫花鸡详情
  #
  def get_jiaohuaji_detail
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    recorder = JiaohuajiRecorder.get_recorders_of_today(user)
    render_result(ResultCode::OK, recorder)
  end

  #
  # 吃叫花鸡
  #
  def eat_jiaohuaji
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    type = params[:type]
    if type.nil? || type.to_i < 0 || type.to_i > 2
      render_result(ResultCode::INVALID_PARAMETERS, {err_msg: 'invalid parameters'})
      return
    end

    type = type.to_i
    if JiaohuajiRecorder.eat(user, type)
      render_result(ResultCode::OK, {})
    else
      render_result(ResultCode::ERROR, {})
    end
  end

  #
  # 获取当前的参拜记录
  #
  def get_canbai_recorders
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    render_result(ResultCode::OK, CanbaiRewardRecorder.get_recorder(user))
  end

  #
  # 参拜接口
  #
  def canbai
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    recorder = CanbaiRewardRecorder.find_by_user_id(user.id)
    if recorder.nil?
      recorder = CanbaiRewardRecorder.new
      recorder.user = user
      recorder.save
    end

    re, goods = recorder.canbai
    unless re
      render_result(ResultCode::ERROR, {err_msg: "error..."})
      return
    end
    render_result(ResultCode::OK, {goods: goods})
  end
end
