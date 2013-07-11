class LunjianController < ApplicationController
  #
  # 获取论剑列表接口
  #
  def get_list
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    list = LunjianPosition.get_list(user)
    render_result(ResultCode::OK, {users: list})
  end

  #
  # 更新挑战结果
  #
  def update_result
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    position = params[:position]
    id = params[:id]
    is_win = params[:is_win]

    if position.nil? || position.to_i < 0 || id.nil? || id.to_i < 0 || is_win.nil? || is_win.to_i < 0
      render_result(ResultCode::INVALID_PARAMETERS, {err_msg: URI.encode('invalid parameters.')})
      return
    end

    user_id = user.id
    position = position.to_i
    id = id.to_i
    is_win = is_win.to_i

    # 点击论剑过后，就不是仇敌了
    relation = Relationship.find_by_user_id_and_friend_id_and_relation_type(user_id, id, Relationship::RELATIONSHIP_ENEMY)
    relation.destroy until relation.nil?

    if is_win == 1
      # 如果挑战成功,则成为仇敌
      Relationship.add(id, user_id, Relationship::RELATIONSHIP_ENEMY)
    end

    code, list =  LunjianPosition.update_result(id, user, position, is_win)
    if code == ResultCode::ERROR
      render_result(ResultCode::ERROR, {err_msg: 'error'})
      return
    end

    render_result(code, {users: list})
  end

  #
  # 刷新积分
  #
  def refresh_recorder
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    lp = LunjianPosition.find_by_user_id(user.id)
    if lp.nil?
      render_result(ResultCode::ERROR, {err_msg: URI.encode('no lunjian position recorder')})
      return
    end

    render_result(ResultCode::OK, lp.to_dictionary())
  end

  #
  # 获取已获得的论剑奖励记录接口
  #
  def get_reward_recorders
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    render_result(ResultCode::OK, LunjianRewardRecorder.get_recorders(user))
  end

  #
  # 添加一个领奖记录
  #
  def add_reward_recorder
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    position = (params[:position] || -1).to_i
    reward = (params[:reward] || -1).to_i
    if position < 0 ||
        (reward != LunjianRewardRecorder::REWARD_300_PEIYANGDAN &&
           reward != LunjianRewardRecorder::REWARD_600_PEIYANGDAN)
      render_result(ResultCode::ERROR, {})
      return
    end
    if LunjianRewardRecorder.add_recorder(user, position, reward)
      render_result(ResultCode::OK, {})
      return
    end
    render_result(ResultCode::ERROR, {})
  end


  #
  # 获取用户被挑战信息(传书)
  #
  def get_defend_messages
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    render_result(ResultCode::OK, LunjianRecorder.get_defend_messages(user.id))
  end


end
