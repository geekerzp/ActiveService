#encoding:utf-8
module SystemHelper
  #
  # 获取系统补偿信息列表
  #
  def get_system_reward_messages
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    user_id = user.id
    system_reward_messages = SystemRewardRecorder.get_system_reward_messages(user_id)
    render_result(ResultCode::OK, {messages: system_reward_messages})
  end

  #
  # 领取系统补偿
  #
  def get_system_reward
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    system_reward_id = params[:system_reward_id]
    if system_reward_id.nil? || system_reward_id.to_i < 0
      return render_result(ResultCode::INVALID_PARAMETERS, {err_msg: 'invalid parameters.'})
    end

    system_reward_record = SystemRewardRecorder.find_by_id(system_reward_id.to_i)
    system_reward_record.receive_or_not = SystemRewardRecorder::RECEIVED
    if system_reward_record.save
      render_result(ResultCode::OK, {})
    else
      render_result(ResultCode::SAVE_FAILED, {err_msg: 'save failed.'})
    end
  end

  #
  # 获取用户系统消息
  #
  def get_system_meesages
    code, messages = current_user.receive_messages

    if code == ResultCode::OK
      render_result(code, { messages: messages })
    else
      render_result(code, { err_msg: URI.encode(messages.to_s) })
    end 
  end 
end
