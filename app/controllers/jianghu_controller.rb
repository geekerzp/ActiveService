#
# 江湖
#
class JianghuController < ApplicationController
  #
  # 获取用户的江湖记录
  #
  def get_jianghu_recorders
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    render_result(ResultCode::OK, user.get_jianghu_recorders)
  end

  #
  # 更新用户江湖记录
  #
  def update_recorder
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    scene_id = params[:scene_id]
    item_id = params[:item_id]
    star = params[:star]
    is_finish = params[:is_finish]

    if scene_id.nil? || scene_id.to_i < 0 || item_id.nil? || item_id.to_i < 0 ||
        star.nil? || star.to_i < 0 || star.to_i > 3 || is_finish.nil? || is_finish.to_i < 0
      render_result(ResultCode::INVALID_PARAMETERS, {err_msg: URI.encode('invalid parameters...')})
      return
    end
    re, err_msg = JianghuRecorder.update_recorder(user, scene_id.to_i, item_id.to_i, star.to_i, is_finish.to_i)
    unless re
      render_result(ResultCode::ERROR, {err_msg: URI.encode(err_msg)})
      return
    end
      render_result(ResultCode::OK, {})
  end

  #
  # 江湖中，如果三星通过所有条目，会有一个吃叫花鸡的奖励。
  #
  def add_jianghu_reward_recorder
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    scene_id = params[:scene_id]
    reward = "item_0048"
    if scene_id.nil? || scene_id.to_i.to_s != scene_id
      render_result(ResultCode::INVALID_PARAMETERS, {})
      return
    end

    jianghu_reward_recorder = JianghuRewardRecorder.new(user_id: user.id, scene_id: scene_id,
                                                        reward: reward)
    jianghu_reward_recorder.save
    render_result(ResultCode::OK, {jianghu_reward_recorder_id: jianghu_reward_recorder.id})
  end
end
