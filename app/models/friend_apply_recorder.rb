require 'message_type'
class FriendApplyRecorder < ActiveRecord::Base
  attr_accessible :applicant_id, :receiver_id, :status

  # 申请状态
  STATUS_NEW     = 0   # 未处理
  STATUS_AGREE   = 1   # 同意
  STATUS_REFUSE  = 2   # 拒绝

  #
  # 检查是否已经申请
  #
  def self.check_apply(user_id, receiver_id)
    friend_apply_record = FriendApplyRecorder.find_by_applicant_id_and_receiver_id(user_id, receiver_id)
    if friend_apply_record.nil?
      false
    else
      if friend_apply_record.status == STATUS_NEW # 还在申请当中
        true
      else
        false
      end
    end
  end

  #
  # 添加申请
  #
  def self.add(user_id, receiver_id)
    apply_recorder = FriendApplyRecorder.new
    apply_recorder.applicant_id = user_id
    apply_recorder.receiver_id = receiver_id
    apply_recorder.status = STATUS_NEW
    apply_recorder.save
  end

  #
  # 获取申请反馈信息
  #
  def self.get_feedback_messages(user_id)
    apply_recorders = FriendApplyRecorder.where('applicant_id = ? AND status != ?', user_id, STATUS_NEW)\
      .order('updated_at desc').limit(10)
    apply_list = []
    apply_recorders.each() do |apply_record|
      apply_hash = {}
      apply_hash[:message_type] =  MessageType::APPLY_FEEDBACK # 申请反馈信息
      apply_hash[:reply_id] = apply_record.receiver_id
      replyer = User.find_by_id(apply_record.receiver_id)
      next if replyer.nil?
      apply_hash[:reply_name] = URI.encode(replyer.name || '')
      if apply_record.updated_at.nil?
        apply_hash[:time] = URI.encode('')
      else
        apply_hash[:time] = URI.encode(apply_record.updated_at.strftime('%Y-%m-%d %H:%M:%S') || '')
      end
      apply_hash[:reply_type] = apply_record.status
      apply_list << apply_hash
    end
    apply_list
  end


  #
  # 获取好友申请信息
  #
  def self.get_apply_messages(user_id)
    apply_recorders = FriendApplyRecorder.where('receiver_id = ? AND status = ?', user_id, STATUS_NEW)\
      .order('updated_at desc').limit(10)
    apply_list = []
    apply_recorders.each() do |apply_record|
      apply_hash = {}
      apply_hash[:message_type] =  MessageType::APPLY_MESSAGE # 申请信息
      apply_hash[:applicant_id] = apply_record.applicant_id
      applicant = User.find_by_id(apply_record.applicant_id)
      next if applicant.nil?
      apply_hash[:applicant_name] = URI.encode(applicant.name || '')
      if apply_record.created_at.nil?
        apply_hash[:time] = URI.encode('')
      else
        apply_hash[:time] = URI.encode(apply_record.created_at.strftime('%Y-%m-%d %H:%M:%S') || '')
      end
      apply_list << apply_hash
    end
    apply_list
  end

end