# vi: set fileencoding=utf-8 :
class Order < ActiveRecord::Base
  # ogmoney为废字段，omoney为用户充值金额
  attr_accessible :csid, :oid, :gid, :ginfo, :gcount, :ogmoney, :omoney, :type, :status, :user_id
  # 表间关系
  belongs_to :user
  # 验证器
  validates :oid, :uniqueness => true

  #
  # 处理用户订单
  # (如果订单处理成功，返回true;
  #  如果订单处理失败，返回false)
  #
  def process
    @user = User.find(self.user_id)                                                  # 获取用户信息
    @recharge_list = ZhangmenrenConfig.instance.market_config["recharge_list"]  # 获取充值信息

    begin
      # 多表事务
      ActiveRecord::Base.transaction do
        Order.transaction do; User.transaction do; UserGoods.transaction do; Equipment.transaction do
        # 用户首次充值
          if @user.orders.count == 1 and self.status == 0
              first_recharge!
          else
              normal_recharge!
          end
        end end end end
      end
    rescue =>e
      logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) process failed #{e.to_s} #{type} 数据处理保存失败 ###")
      false   # 充值失败
    end
  end

  #
  # 生成空订单
  #
  def create_blank_order(uid,oid,status)
    self.user_id = uid
    self.oid = oid
    self.status = status
    return true if self.save
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
    rule = @recharge_list.find{|x| x["id"] == gid}    # 找到对应的充值规则

    unless rule.nil?
      @user.gold= @user.gold + (rule["get"]+rule["present"])*2        # 元宝
      @user.silver= @user.silver + 1000000                            # 额外赠送
      Equipment.create_equipment(user, 'equipment_horse_2007').save!  # 坐骑 乌孙
      # 训练丹
      goods_config = ZhangmenrenConfig.instance.goods_config
      goods_info =  goods_config["item_0047"]
      if goods_info.nil?
        logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) good not exists 道具信息不存在 ###")
        raise "good not exists"
      end
      # 更新用户道具记录
      user_goods = UserGoods.find_by_g_type_and_user_id("item_0047", user_id)
      if user_goods.nil?
        user_goods = UserGoods.new
        user_goods.user = @user
        user_goods.g_type = "item_0047"
        user_goods.number = 100
      else
        user_goods.number += 100
      end
      user_goods.save!
      @user.save!
      self.status= 1 # 充值成功
      self.save!
      return true
    end

    logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) first_recharge failed 对应规则不存在 ###")
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
      @user.gold= @user.gold + (rule["get"]+rule["present"])    # 元宝
      @user.save!
      self.status= 1 # 充值成功
      self.save!
      return true
    end

    logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) normal_recharge failed 对应规则不存在 ###")
    false
  end
end
