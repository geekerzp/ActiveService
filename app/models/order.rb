class Order < ActiveRecord::Base
  attr_accessible :csid, :oid, :gid, :ginfo, :gcount, :ogmoney, :omoney, :type, :status, :user_id

  belongs_to :user

  #
  # 处理用户订单
  #
  def process
    # 获取用户信息
    user = User.find(user_id)
    # 获取充值信息
    recharge_list = ZhangmenrenConfig.instance.market_config["recharge_list"]

    begin
      Order.transaction do
        # 用户首次充值
        if user.orders.count == 0
          # 找到对应的充值规则
          if (rule = recharge_list.find{|x| x["money"] == omoney })
            # 元宝
            user.gold= user.gold + (rule["get"]+rule["present"])*2

            # 额外赠送
            user.silver= user.silver + 10000000
            Equipment.create_equipment(user, 'equipment_horse_2007')

            self.status= 1 # 充值成功
            true
          else
            self.status= 2 # 充值失败
            false
          end
        else
        # 常规充值
        # 找到对应的充值规则
          if (rule = recharge_list.find{|x| x["money"] == omoney })
            # 元宝
            user.gold= user.gold + (rule["get"]+rule["present"])

            self.status= 1 # 充值成功
            true
          else
            self.status= 2 # 充值失败
            false
          end
        end
      end
    rescue
      false # 事务失败
    end
  end
  def create_blank_order(uid,oid,status)
    self.user_id = uid
    self.oid = oid
    self.status = status

    self.save
  end

end
