# vi: set fileencoding=utf-8 :
require 'second_level_cache/second_level_cache'
require 'message_type'

class CanzhangGrabRecorder < ActiveRecord::Base
  acts_as_cached(version: 1, expires_in: 1.week)  # 开启二级缓存

  attr_accessible :attacker_id, :defender_id, :who_win, :cz_type

  #
  # 添加残章夺取记录
  #
  # @param [Integer] attacker_id      攻击者id
  # @param [Integer] defender_id      防御者id
  # @param [Integer] winner_id        胜利者id
  # @param [String] canzhang_type     残章类型
  #
  def self.add_recorder(attacker_id, defender_id, winner_id, canzhang_type)
    recorder = CanzhangGrabRecorder.new
    recorder.attacker_id = attacker_id
    recorder.defender_id = defender_id
    recorder.who_win = winner_id
    recorder.cz_type = URI.encode(canzhang_type || '')
    recorder.save
  end

  #
  # 获取用户被夺残章信息(传书)
  #
  # @param [integer] user_id 用户id
  #
  def self.get_grabbed_messages(user_id)
    recorders_array = []
    canzhang_recorders = CanzhangGrabRecorder.where('defender_id = ?', user_id).order('created_at desc').limit(10)
    canzhang_recorders.each() do |canzhang_recorder|
      recorder_hash = {}
      recorder_hash[:message_type] = MessageType::GRAB_CANZHANG # 被夺残章类型的消息
      recorder_hash[:canzhang_type] = URI.encode(canzhang_recorder.cz_type || '')
      if user_id == canzhang_recorder.who_win
        recorder_hash[:win_or_not] = 1
      else
        recorder_hash[:win_or_not] = 2
      end
      if canzhang_recorder.created_at.nil?
        recorder_hash[:time] = URI.encode('')
      else
        recorder_hash[:time] = URI.encode(canzhang_recorder.created_at.strftime('%Y-%m-%d %H:%M:%S'))
      end
      recorders_array << recorder_hash
    end
    return recorders_array
  end
end
