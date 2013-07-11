class LunjianRewardRecorder < ActiveRecord::Base
  attr_accessible :position, :reward, :user_id

  belongs_to :user

  # 奖励类型
  REWARD_300_PEIYANGDAN = 1 # 300培养单
  REWARD_600_PEIYANGDAN = 2 # 600培养单

  def to_dictionary
    tmp = {}
    tmp[:id] = self.id
    tmp[:position] = self.position
    tmp[:reward] = self.reward
    tmp[:user_id] = self.user_id
    tmp
  end

  #
  # 获取记录列表
  # @param [User] user 用户
  def self.get_recorders(user)
    list = []
    user.lunjian_reward_recorders.each() {|r| list << r.to_dictionary }
    list
  end

  #
  # 创建一个领奖记录
  #
  # @param [User] user        用户
  # @param [Integer] position 领奖的位置
  # @param [Integer] reward   奖品类型
  # @return [Boolean]         添加成功返回true，否则返回false
  def self.add_recorder(user, position, reward)
    reward_position = LunjianRewardRecorder.get_reward_position(position)
    return false if reward_position < 0
    return false if LunjianRewardRecorder.exists?(position: reward_position, user_id: user.id)
    recorder = LunjianRewardRecorder.new(position: reward_position, reward: reward, user_id: user.id)
    recorder.save
  end

  #
  # 根据参数position对应的位置，计算其对应的奖励位置。
  # 名次第一次达到1000,500,200,100,50可以领取300培养丹，
  # 名次第一次达到10,1可以领取600培养丹。
  #
  def self.get_reward_position(position)
    position = position.to_i
    [1, 10, 50, 100, 200, 500, 1000].each() do |p|
      return p if position <= p
    end
    return -1
  end
end
