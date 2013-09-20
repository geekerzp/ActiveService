# vi: set fileencoding=utf-8 :
require 'second_level_cache/second_level_cache'
require 'message_type'

class LunjianRecorder < ActiveRecord::Base
  acts_as_cached(version: 1, expires_in: 1.week)  # 开启二级缓存

  attr_accessible :attacker_id, :defender_id, :who_win

  belongs_to :attacker, :foreign_key => 'attacker_id', :class_name => 'User'
  belongs_to :defender, :foreign_key => 'defender_id', :class_name => 'User'

  validates :attacker_id, :defender_id, :who_win, :presence => true
  validates :attacker_id, :defender_id, :numericality => {:greater_than_or_equal_to => 0,
                                                                                 :only_integer => true}
  validates :who_win, :inclusion => {:in => [1, 2]}

  ATTACKER_WIN = 1  # 进攻者赢
  DEFENDER_WIN = 2  # 防御者赢


  #
  # 获取用户被挑战信息(传书)
  # @param [integer] user_id 用户id
  #
  def self.get_defend_messages(user_id)
    recorders_array = []
    lunjian_recorders = LunjianRecorder.where('defender_id = ?', user_id).order('created_at desc').limit(10)
    lunjian_recorders.each() do |lunjian_recorder|
      recorder_hash = {}
      recorder_hash[:message_type] = MessageType::LUNJIAN_DEFEND # 论剑被挑战类型的消息
      recorder_hash[:attacker_id] = lunjian_recorder.attacker_id
      lunjian_position_attacker = LunjianPosition.find_by_user_id(lunjian_recorder.attacker_id)
      if lunjian_position_attacker.nil?
        recorder_hash[:attacker_position] = LunjianPosition.all.size
      else
        recorder_hash[:attacker_position] = lunjian_position_attacker.position
      end

      lunjian_position_defender = LunjianPosition.find_by_user_id(user_id)
      if lunjian_position_defender.nil?
        recorder_hash[:defender_position] = LunjianPosition.all.size
      else
        recorder_hash[:defender_position] = lunjian_position_defender.position
      end
      if user_id == lunjian_recorder.who_win
        recorder_hash[:win_or_not] = 1
      else
        recorder_hash[:win_or_not] = 2
      end
      if lunjian_recorder.created_at.nil?
        recorder_hash[:time] = URI.encode('')
      else
        recorder_hash[:time] = URI.encode(lunjian_recorder.created_at.strftime('%Y-%m-%d %H:%M:%S') || '')
      end

      recorders_array << recorder_hash
    end
    return recorders_array
  end


end
