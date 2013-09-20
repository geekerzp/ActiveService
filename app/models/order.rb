# vi: set fileencoding=utf-8 :

class Order < ActiveRecord::Base
  # ogmoney为废字段，omoney为用户充值金额
  attr_accessible :csid, :oid, :gid, :ginfo, :gcount, :ogmoney, :omoney, :o_type, :status, :user_id

  belongs_to :user

  validates :oid, :uniqueness => true

  #
  # 处理用户订单
  # (如果订单处理成功，返回true;
  #  如果订单处理失败，返回false)
  #
  def process
    @recharge_list  = ZhangmenrenConfig.instance.market_config["recharge_list"]   # 获取充值信息
    Order.transaction do
      @user = User.where(id: self.user_id).lock(true).first                       # 获取用户信息
      # 用户首次充值
        if @user.orders.lock(true).count == 1 and self.status == 0
            first_recharge!
            logger.info "### #{__method__},(#{__FILE__}, #{__LINE__}) order process successed #{o_type} 订单处理成功"
        else
            normal_recharge!
            logger.info "### #{__method__},(#{__FILE__}, #{__LINE__}) order process successed #{o_type} 订单处理成功"
        end
    end
  rescue => e
    logger.error "### #{__method__},(#{__FILE__}, #{__LINE__}) order process failed #{e.to_s} #{o_type} 订单处理失败"
    false   # 充值失败
  end

  #
  # 生成空订单
  #
  def create_blank_order(uid,oid,status)
    self.user_id  = uid
    self.oid      = oid
    self.status   = status

    return true if self.save
    logger.error "##### #{__method__},(#{__FILE__}, #{__LINE__}) create blank order failed #{o_type} 生成空订单失败"
    false
  end

  private
  #
  # 首次充值
  # (如果数据保存成功，返回true;
  #  如果数据保存失败或道具信息不存在，抛出异常;
  #  如果规则不存在，返回false)
  #
  def first_recharge!
    rule = @recharge_list.find {|x| x["id"] == gid }    # 找到对应的充值规则

    unless rule.nil?
      @user.gold    = @user.gold + (rule["get"]+rule["present"])*2    # 元宝
      @user.silver  = @user.silver + 1000000                          # 额外赠送
      Equipment.create_equipment(user, 'equipment_horse_2007').save!  # 坐骑 乌孙

      # 训练丹
      goods_config  = ZhangmenrenConfig.instance.goods_config
      goods_info    =  goods_config["item_0047"]
      if goods_info.nil?                                              # 道具信息不存在抛出异常
        logger.error "##### #{__method__},(#{__FILE__}, #{__LINE__}) good not exists 道具信息不存在"
        raise "good not exists 道具不存在"
      end

      # 更新用户道具记录
      user_good = UserGood.where(g_type: "item_0047", user_id: user_id).lock(true).first
      if user_good.nil?
        user_good        = UserGood.new
        user_good.user   = @user
        user_good.g_type = "item_0047"
        user_good.number = 100
      else
        user_good.number += 100
      end
      user_good.save!

      @user.save!

      self.status= 1 # 充值成功
      self.save!

      logger.info "### #{__method__},(#{__FILE__}, #{__LINE__}) first_recharge successed 首次充值成功"
      return true
    end

    logger.error "##### #{__method__},(#{__FILE__}, #{__LINE__}) first_recharge failed 对应规则不存在"
    false
  end

  #
  # 正常充值
  # (如果数据保存成功，返回true;
  #  如果数据保存失败，抛出异常;
  #  如果规则不存在，返回false)
  #
  def normal_recharge!    
    rule = @recharge_list.find{|x| x["id"] == gid}    # 找到对应的充值规则

    unless rule.nil?
      @user.gold = @user.gold + (rule["get"]+rule["present"])    # 元宝
      @user.save!

      self.status = 1 # 充值成功
      self.save!

      logger.info "### #{__method__},(#{__FILE__}, #{__LINE__}) normal_recharge successed 普通充值成功"
      return true
    end

    logger.error "##### #{__method__},(#{__FILE__}, #{__LINE__}) normal_recharge failed 对应规则不存在"
    false
  end
end
