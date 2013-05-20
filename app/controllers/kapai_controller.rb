class KapaiController < ApplicationController

  #
  # 更新弟子信息
  #
  def update_disciples
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    disciples = params[:disciples]
    if disciples.nil? || !disciples.kind_of?(Array)
      render_result(ResultCode::INVALID_PARAMETERS, {err_msg: URI.encode('invalid parameters')})
      return
    end

    re, err_msg = Disciple.update_disciples(user, disciples)
    unless re
      logger.error(err_msg)
      render_result(ResultCode::ERROR, {err_msg: URI.encode(err_msg)})
      return
    end
    render_result(ResultCode::OK, {})
  end

  #
  # 更新装备信息
  #
  def update_equipments
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    equipments = params[:equipments]
    if equipments.nil? || !equipments.kind_of?(Array)
      render_result(ResultCode::INVALID_PARAMETERS, {err_msg: URI.encode('invalid parameters')})
      return
    end

    re, err_msg = Equipment.update_equipments(user, equipments)
    unless re
      logger.error(err_msg)
      render_result(ResultCode::ERROR, {err_msg: URI.encode(err_msg)})
      return
    end
    render_result(ResultCode::OK, {})
  end

  #
  # 更新武功信息
  #
  def update_gongfus
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    gongfus = params[:gongfus]
    if gongfus.nil? || !gongfus.kind_of?(Array)
      logger.debug("invalid parameters. gongfus is not an array.")
      render_result(ResultCode::INVALID_PARAMETERS, {err_msg: URI.encode('invalid parameters')})
      return
    end

    re, err_msg = Gongfu.update_gongfus(user, gongfus)
    unless re
      logger.error(err_msg)
      render_result(ResultCode::ERROR, {err_msg: URI.encode(err_msg)})
      return
    end
    render_result(ResultCode::OK, {})
  end

  #
  # 更新掌门诀
  #
  def update_zhangmenjues
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    zhangmenjues = params[:zhangmenjues]
    if zhangmenjues.nil? || !zhangmenjues.kind_of?(Array)
      logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) invalid parameters. zhangmenjues is not an array.")
      render_result(ResultCode::INVALID_PARAMETERS, {err_msg: URI.encode('invalid parameters')})
      return
    end

    re, err_msg = Zhangmenjue.update_zhangmenjues(user, zhangmenjues)
    unless re
      logger.error(err_msg)
      render_result(ResultCode::ERROR, {err_msg: URI.encode(err_msg)})
      return
    end
    render_result(ResultCode::OK, {})
  end

  #
  # 更新魂魄接口
  #
  def update_souls
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    souls = params[:souls]
    if souls.nil? || !souls.kind_of?(Array)
      logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) invalid parameters. souls is not an array.")
      render_result(ResultCode::INVALID_PARAMETERS, {err_msg: URI.encode('invalid parameters')})
      return
    end

    re, err_msg = Soul.update_souls(user, souls)
    unless re
      logger.error(err_msg)
      render_result(ResultCode::ERROR, {err_msg: URI.encode(err_msg)})
      return
    end
    render_result(ResultCode::OK, {})
  end

  #
  # 创建一个武功
  #
  def create_gongfu
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    type = get_params(params, :type)
    gongfu = Gongfu.create_gongfu(user, type)
    if gongfu.nil?
      render_result(ResultCode::ERROR, {err_msg: URI.encode("create gongfu error")})
      return
    end
    unless gongfu.save
      err_msg = gongfu.errors.full_messages.join('; ')
      logger.error("### #{__method__},(#{__FILE__}, #{__LINE__})  #{err_msg}")
      render_result(ResultCode::ERROR, {err_msg: URI.encode(err_msg)})
      return
    end
    render_result(ResultCode::OK, {id: gongfu.id})
  end

  #
  # 创建一个装备
  #
  def create_equipment
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    type = get_params(params, :type)

    eq = Equipment.new(e_type: type, level: 0, grow_strength: 0.0,
                       user_id: user.id, position: -1, disciple_id: -1)
    unless eq.save
      err_msg = eq.errors.full_messages.join('; ')
      logger.error("### #{__method__},(#{__FILE__}, #{__LINE__})  #{err_msg}")
      render_result(ResultCode::ERROR, {err_msg: URI.encode(err_msg)})
      return
    end
    render_result(ResultCode::OK, {id: eq.id})
  end

  #
  # 创建一个弟子
  #
  def create_disciple
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    type = get_params(params, :type)

    disciple = Disciple.create_disciple(user, type)
    if disciple.nil?
      render_result(ResultCode::ERROR, {err_msg: URI.encode("create disciple error")})
      return
    end
    unless disciple.save
      err_msg = disciple.errors.full_messages.join('; ')
      logger.error("### #{__method__},(#{__FILE__}, #{__LINE__})  #{err_msg}")
      render_result(ResultCode::ERROR, {err_msg: URI.encode(err_msg)})
      return
    end
    render_result(ResultCode::OK, {id: disciple.id, origin_gongfu_id: disciple.gongfus[0].id})
  end
end
