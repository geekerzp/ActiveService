class Order < ActiveRecord::Base
  # 读写器
  attr_accessible :csid, :oid, :gid, :ginfo, :gcount, :ogmoney, :omoney, :type, :status, :user_id
  # 表间关系
  belongs_to :user
  # 验证器
  validates :oid, :uniqueness => true

  def initialize
    @recharge_recorder = RechargeRecorder.new   # 新建充值记录
  end

  #
  # 处理用户订单
  #
  def process
    # 获取用户信息
    @user = User.find(user_id)
    @recharge_recorder.user_id = user_id
    # 获取充值信息
    @recharge_list = ZhangmenrenConfig.instance.market_config["recharge_list"]

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
      logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) process failed #{e.to_s} #{type}")
      false # 充值失败
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
  #
  def first_recharge!
    # 找到对应的充值规则
    rule = @recharge_list.find{|x| x["id"] == gid}

    unless rule.nil?
      # 元宝
      @user.gold= @user.gold + (rule["get"]+rule["present"])*2
      @recharge_recorder.gold = (rule["get"]+rule["present"]*2)

      # 额外赠送
      # 坐骑 乌孙
      @user.silver= @user.silver + 1000000
      @recharge_recorder.silver = 1000000
      Equipment.create_equipment(user, 'equipment_horse_2007').save!

      # 训练丹
      goods_config = ZhangmenrenConfig.instance.goods_config
      goods_info =  goods_config["item_0047"]
      if goods_info.nil?
        logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) good not exists")
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

      @recharge_recorder.save!
      return true
    end
    logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) first_recharge failed")
    false
  end

  #
  # 正常充值
  #
  def normal_recharge!
    # 找到对应的充值规则
    rule = @recharge_list.find{|x| x["id"] == gid}

    unless rule.nil?
      # 元宝
      @user.gold= @user.gold + (rule["get"]+rule["present"])
      @recharge_recorder.gold = (rule["get"]+rule["present"])

      @user.save!

      self.status= 1 # 充值成功
      self.save!

      @recharge_recorder.save!
      return true
    end
    logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) normal_recharge failed")
    false
  end
end
