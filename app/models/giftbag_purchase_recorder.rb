# vi: set fileencoding=utf-8 :
require 'second_level_cache/second_level_cache'

class GiftbagPurchaseRecorder < ActiveRecord::Base
  acts_as_cached(version: 1, expires_in: 1.week)  # 开启二级缓存

  attr_accessible :name, :number, :user_id, :is_open

  #
  # 获取用户礼包列表
  #
  def self.get_list(user)
    bags = GiftbagPurchaseRecorder.where(user_id: user.id).order('created_at asc')
    list = []
    bags.each() do |bag|
      tmp = {}
      tmp[:id] = bag.id
      tmp[:number] = bag.number
      tmp[:is_open] = bag.is_open ? 1 : 0
      tmp[:name] = URI.encode(bag.name || '')
      list << tmp
    end
    list
  end

  #
  # 购买礼包
  #
  # @param [User] user      用户
  # @param [String] name    礼包名称
  # @param [Integer] number 数量
  def self.buy_gift_bags(user, name, number)
    giftbags_config = ZhangmenrenConfig.instance.gift_bag_config
    giftbag_info = giftbags_config[name]
    if giftbag_info.nil?
      logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) no such giftbags #{name}")
      return false
    end
    price = (giftbag_info['actual_price'] || 0).to_i
    if user.gold < (price * number).to_i
      logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) no enough gold. #{user.gold} < #{price * number}")
      return false
    end

    # 扣除元宝
    user.gold -= (price * number).to_i

    # 创建购买记录
    gpr = GiftbagPurchaseRecorder.new
    gpr.name = name
    gpr.number = number
    gpr.user_id = user.id
    gpr.is_open = false

    err_msg = ""
    unless user.save && gpr.save
      err_msg << user.errors.full_messages.join('; ')
      err_msg << gpr.errors.full_messages.join('; ')
      logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) #{err_msg}")
      return false
    end
    true
  end
end
