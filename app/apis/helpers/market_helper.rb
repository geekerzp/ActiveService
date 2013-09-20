#encoding:utf-8
module MarketHelper
  #
  # 收徒
  #
  def obtain_disciple
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    type = params[:type]
    if type.nil? || type.to_i < 0 || type.to_i > 3
      return render_result(ResultCode::INVALID_PARAMETERS, {err_msg: 'invalid parameters.'})
    end

    type = type.to_i
    disciple_type, soul_or_disciple, is_use_gold = ObtainDiscipleRecorder.obtain(user, type)
    if disciple_type.nil? || soul_or_disciple.nil?
      render_result(ResultCode::ERROR, {err_msg: 'error'})
    else
      render_result(ResultCode::OK, {type: soul_or_disciple,
                                     disciple_type: disciple_type,
                                     is_use_gold: is_use_gold})
    end
  end

  #
  # 购买道具
  #
  def buy_goods
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    name = get_params(params, :name)
    number = (params[:number] || 1).to_i

    unless GoodsPurchaseRecorder.buy_goods(user, name, number)
      return render_result(ResultCode::ERROR, {err_msg: 'error...'})
    end
    render_result(ResultCode::OK, {})
  end

  #
  # 获取我的礼包列表
  #
  def get_my_gift_bags
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re
    render_result(ResultCode::OK, {gift_bags: GiftbagPurchaseRecorder.get_list(user)})
  end

  #
  # 购买礼包
  #
  def buy_gift_bag
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    name = get_params(params, :type)
    number = (params[:number] || 1).to_i

    unless GiftbagPurchaseRecorder.buy_gift_bags(user, name, number)
      render_result(ResultCode::ERROR, {err_msg: 'error...'})
      return
    end
    render_result(ResultCode::OK, {})
  end

  #
  # 打开礼包
  #
  def open_gift_bag
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    gpr = GiftbagPurchaseRecorder.find_by_name_and_user_id(params[:type], user.id)
    if gpr.nil?
      render_result(ResultCode::NO_GIFTBAG_PURCHASE_RECORDER_FOUND, {err_msg: 'no giftbag purchase recorder found.'})
      return
    end

    unless gpr.update_attribute(:is_open, true)
      render_result(ResultCode::SAVE_FAILED, {err_msg: 'save failed.'})
      return
    end
    render_result(ResultCode::OK, {})
  end

  #
  # 获取收徒记录接口
  #
  def get_obtain_disciple_recorders
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    render_result(ResultCode::OK, {list: ObtainDiscipleRecorder.get_recorders_list(user),
                                   server_time: Time.now.to_s})
  end
end