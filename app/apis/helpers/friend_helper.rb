#encoding: utf-8
#
# 好友
#
require 'comm'
include Comm
module FriendHelper
  #
  # 申请好友
  #
  def apply
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    receiver_id = params[:receiver_id]
    if receiver_id.nil? || receiver_id.to_i < 0
      return render_result(ResultCode::INVALID_PARAMETERS, {err_msg: 'invalid parameters.'})
    end

    user_id = user.id
    receiver_id = receiver_id.to_i
    #如果已经是好友,不能申请成功
    if Relationship.check_relationship(user_id, receiver_id, Relationship::RELATIONSHIP_FRIEND)
      return render_result(ResultCode::ALREADY_FRIENDS, {err_msg: 'already friends, do not have to apply.'})
    end

    # 如果之前已经申请过, 不能再申请
    if FriendApplyRecorder.check_apply(user_id, receiver_id)
      return render_result(ResultCode::ALREADY_APPLIED, {err_msg: 'already applied.'})
    end

    # 如果好友上限超过其对应的vip上限，不能再申请
    friends_size = Relationship.where('user_id = ? AND relation_type = ?', user_id,
                                      Relationship::RELATIONSHIP_FRIEND).size
    if user.vip_level < 1
      friends_limit = ZhangmenrenConfig.instance.vip_config['1']['max_friends'].to_i
    elsif user.vip_level > 12
      friends_limit = ZhangmenrenConfig.instance.vip_config['12']['max_friends'].to_i
    else
      friends_limit = ZhangmenrenConfig.instance.vip_config[user.vip_level.to_s]['max_friends'].to_i
    end

    if friends_size > friends_limit
      return render_result(ResultCode::BEYOND_FRIEND_LIMIT, {err_msg: 'beyond friends number limit.'})
    end

    # 添加好友申请
    if FriendApplyRecorder.add(user_id, receiver_id)
      render_result(ResultCode::OK, {})
    else
      render_result(ResultCode::SAVE_FAILED, {err_msg: 'save failed.'})
    end
  end

  #
  # 关注仇敌
  #
  def follow
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    receiver_id = params[:receiver_id]
    if receiver_id.nil? || receiver_id.to_i < 0
      return render_result(ResultCode::INVALID_PARAMETERS, {})
    end

    user_id = user.id
    receiver_id = receiver_id.to_i
    # 如果已经关注过,不能再关注
    if Relationship.check_relationship(user_id, receiver_id, Relationship::RELATIONSHIP_FOLLOW)
      return render_result(ResultCode::ALREADY_FOLLOWS, {err_msg: 'already follows, do not have to follow.'})
    end

    # 如果关注上限超过其对应的vip上限，不能再关注
    follow_size = Relationship.where('user_id = ? AND relation_type = ?', user_id,
                                      Relationship::RELATIONSHIP_FOLLOW).size
    follow_limit = ZhangmenrenConfig.instance.vip_config[user.vip_level.to_s]['max_following'].to_i
    if follow_size > follow_limit
      return render_result(ResultCode::BEYOND_FOLLOW_LIMIT, {err_msg: 'beyond follow number limit.'})
    end

    # 添加仇敌关系
    if Relationship.add(user_id, receiver_id, Relationship::RELATIONSHIP_FOLLOW)
      render_result(ResultCode::OK, {})
    else
      render_result(ResultCode::SAVE_FAILED, {err_msg: 'save failed.'})
    end
  end

  #
  # 回复好友申请接口
  #
  def reply_apply
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    sender_id = params[:sender_id]
    reply_type = params[:reply_type]
    if sender_id.nil? || sender_id.to_i < 0 || reply_type.nil? || reply_type.to_i < 0
      return render_result(ResultCode::INVALID_PARAMETERS, {err_msg: 'invalid parameters.'})
    end

    user_id = user.id
    sender_id = sender_id.to_i
    reply_type = reply_type.to_i
    apply_recorder = FriendApplyRecorder.find_by_applicant_id_and_receiver_id(sender_id, user_id)
    if reply_type == 1
      apply_recorder.status = FriendApplyRecorder::STATUS_AGREE # 同意
      # 将两个用户互相加为好友
      Relationship.add(user_id, sender_id, Relationship::RELATIONSHIP_FRIEND)
    elsif reply_type == 2
      apply_recorder.status = FriendApplyRecorder::STATUS_REFUSE # 拒绝
    else
      return render_result(ResultCode::INVALID_PARAMETERS, {err_msg: 'invalid parameters.'})
    end

    if apply_recorder.save
      render_result(ResultCode::OK, {})
    else
      render_result(ResultCode::SAVE_FAILED, {err_msg: 'save failed.'})
    end
  end

  #
  # 给好友留言接口
  #
  def leave_message
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    receiver_id = params[:receiver_id]
    message = get_params(params, :message)
    if receiver_id.nil? || receiver_id.to_i < 0 || message.nil? || message.length < 0
      return render_result(ResultCode::INVALID_PARAMETERS, {err_msg: 'invalid parameters.'})
    end

    user_id = user.id
    receiver_id = receiver_id.to_i
    message = message.to_s

    user_message = Message.new
    user_message.sender_id = user_id
    user_message.receiver_id = receiver_id
    user_message.message = message
    if user_message.save
      render_result(ResultCode::OK, {})
    else
      render_result(ResultCode::SAVE_FAILED, {err_msg: 'save failed.'})
    end
  end

  #
  # 获取关系用户列表接口
  #
  def get_relation_user_list
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    relation_type = params[:relation_type]
    if relation_type.nil? || relation_type.to_i < 0 || relation_type.to_i > 3
      return render_result(ResultCode::INVALID_PARAMETERS, {err_msg: 'invalid parameters.'})
    end

    user_id = user.id
    relation_type = relation_type.to_i
    render_result(ResultCode::OK, {users: Relationship.get_relationship(user_id, relation_type)})
  end


  #
  # 获取留言列表接口
  #
  def get_message_list
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    user_id = user.id
    messages_array = []

    # 好友留言信息
    leave_messages = Message.get_leave_messages(user_id)
    leave_messages.each do |leave_message|
      messages_array << leave_message
    end

    # 好友申请信息
    apply_messages = FriendApplyRecorder.get_apply_messages(user.id)
    apply_messages.each do |apply_message|
      messages_array << apply_message
    end

    # 申请好友反馈信息
    apply_feedback_messages = FriendApplyRecorder.get_feedback_messages(user_id)
    apply_feedback_messages.each do |apply_feedback_message|
      messages_array << apply_feedback_message
    end

    messages_array = sort_time_desc(messages_array)
    render_result(ResultCode::OK, {messages: messages_array})
  end
end