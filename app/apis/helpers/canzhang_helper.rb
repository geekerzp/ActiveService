#encoding: utf-8
module CanzhangHelper
	def get_list
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    type = get_params(params, :type)
    limit = (params[:limit] || 3).to_i
    list = Canzhang.get_list(user, type, limit)
    return render_result(ResultCode::OK, {users: list})
  end

  #
  # 更新抢夺残章的战斗结果
  #
  def update_result
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    type = get_params(params, :type)
    user_id = params[:user_id].to_i
    is_win = params[:is_win].to_i  # 1：赢了，0：输了

    canzhang = Canzhang.update_result(user, type, user_id, is_win)
    if canzhang.nil?
      # 尽管残章夺取失败，但是还是需要记录残章夺取记录
      CanzhangGrabRecorder.add_recorder(user.id, user_id, user_id, type)
      return render_result(ResultCode::OK, {is_grab: 0})
    end
    data = canzhang.to_dictionary
    data[:is_grab] = 1
    # 残章夺取成功，也需要记录残章夺取记录
    CanzhangGrabRecorder.add_recorder(user.id, user_id, user_id, type)
    return render_result(ResultCode::OK, data)
  end

  #
  # 获取我拥有的残章
  #
  def get_my_canzhangs
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    canzhangs = []
    user.canzhangs.each() {|cz| canzhangs << cz.to_dictionary}
    return render_result(ResultCode::OK, canzhangs)
  end

  #
  # 更新残章接口
  #
  def update_canzhangs
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    canzhangs = params[:canzhangs]
    if canzhangs.nil? || !canzhangs.kind_of?(Array)
      return render_result(ResultCode::INVALID_PARAMETERS, {err_msg: 'canzhangs must be an array.'})
    end

    Canzhang.update_canzhangs(canzhangs)
    render_result(ResultCode::OK, {})
  end


  #
  # 获取用户被夺残章信息(传书)
  #
  def get_grabbed_messages
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    render_result(ResultCode::OK, CanzhangGrabRecorder.get_grabbed_messages(user.id))
  end

  #
  # 创建一个用户的残章
  #
  def create_canzhang
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    cz_type = get_params(params, :type)
    number = params[:number].to_i

    if(cz_type.nil?||number.nil?)
      return render_result(ResultCode::INVALID_PARAMETERS,{err_msg:'cz_type or number is nil'})
    end

    canzhang = Canzhang.create_canzhang(cz_type, number, user.id)
    if(canzhang.nil?)
      return render_result(ResultCode::ERROR,{err_msg:'create canzhang failed'})
    end

    data = canzhang.to_dictionary

    render_result(ResultCode::OK,data)
  end
end