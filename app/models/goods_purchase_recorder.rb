class GoodsPurchaseRecorder < ActiveRecord::Base
  attr_accessible :name, :number, :user_id

  #
  # 购买道具
  #
  # @param [User] user      当期用户
  # @param [String] type    道具类型
  # @param [Integer] number 数量
  def self.buy_goods(user, type, number)
    goods_config = ZhangmenrenConfig.instance.goods_config
    goods_info = goods_config[type]
    if goods_info.nil?
      logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) no such goods #{type}")
      return false
    end

    goods_price = (goods_info['price'] || 0).to_f
    if user.gold < (goods_price * number).to_i
      logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) user's gold is not enough. #{user.gold} < #{goods_price * number}")
      return false
    end

    # 扣除元宝数
    user.gold -= (goods_price * number).to_i

    # 创建购买记录
    gpr = GoodsPurchaseRecorder.new
    gpr.name = type
    gpr.number = number
    gpr.user_id = user.id

    # 更新用户道具记录
    user_goods = UserGoods.find_by_g_type_and_user_id(type, user.id)
    if user_goods.nil?
      user_goods = UserGoods.new
      user_goods.user = user
      user_goods.g_type = type
      user_goods.number = 0
    end
    user_goods.number += number

    err_msg = ""
    unless user.save && gpr.save && user_goods.save
      err_msg << user.errors.full_messages.join('; ')
      err_msg << gpr.errors.full_messages.join('; ')
      err_msg << user_goods.errors.full_messages.join('; ')
      logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) #{err_msg}")
      return false
    end
    true
  end

end
