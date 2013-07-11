class JiaohuajiRecorder < ActiveRecord::Base
  attr_accessible :r_type, :user_id

  belongs_to :user

  # 吃叫花鸡的时间
  EAT_AT_NOON       = 1 # 中午
  EAT_AT_AFTERNOON  = 2 # 下午

  #
  # 获取user今天吃叫花鸡的记录
  #
  # @param [User] user 用户
  def self.get_recorders_of_today(user)
    now = Time.now
    today_string = now.strftime('%F')
    recorders = user.jiaohuaji_recorders.where(eat_at: today_string)
    result = {is_eat_at_noon: 0, is_eat_at_afternoon: 0}
    recorders.each() do |recorder|
      result[:is_eat_at_noon] = 1 if recorder.r_type == EAT_AT_NOON
      result[:is_eat_at_afternoon] = 1 if recorder.r_type == EAT_AT_AFTERNOON
    end
    result[:server_time] = URI.encode(now.strftime('%F %T') || '')
    result
  end

  #
  # 吃叫花鸡
  #
  # @param [User] user    用户
  # @param [Integer] type 类型
  def self.eat(user, type)
    now = Time.now
    today_string = now.strftime('%F')
    unless JiaohuajiRecorder.find_by_user_id_and_eat_at_and_r_type(user.id, today_string, type).nil?
      # 已经吃过了
      return false
    end
    recorder = JiaohuajiRecorder.new
    recorder.user = user
    recorder.r_type = type
    recorder.eat_at = today_string
    recorder.save
  end
end
