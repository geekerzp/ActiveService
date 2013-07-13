class CanbaiRewardRecorder < ActiveRecord::Base
  attr_accessible :accumulated_continuous_time, :last_canbai_time, :r_type, :user_id
  belongs_to :user

  #
  # 获取user当前的参拜记录
  #
  def self.get_recorder(user)
    recorder = user.canbai_reward_recorder
    if recorder.nil?
      recorder = CanbaiRewardRecorder.new
      recorder.user = user
      recorder.save
    end

    # 参拜不连续，清零。最近一次参拜时间既不是今天也不是昨天。
    if recorder.last_canbai_time != Time.now.to_date.yesterday && recorder.last_canbai_time != Time.now.to_date
      recorder.accumulated_continuous_time = 0
      recorder.save
    end

    re = {}
    re[:type] = recorder.r_type.to_i
    re[:continuous_time] = recorder.accumulated_continuous_time
    re[:server_time] = URI.encode(Time.now.strftime('%F %T'))
    re[:last_canbai_time] = URI.encode(recorder.last_canbai_time.strftime('%F'))
    re
  end

  #
  # 参拜
  #
  # @return [Boolean, Array] 成功则返回ture，失败返回false。如果获得物品，则同时返回物品列表，否则是[]
  def canbai
    # 增加参拜次数
    return false, [] unless increase_canbai_time()

    logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) type #{r_type} time #{accumulated_continuous_time}.")

    goods = []
    if self.r_type == self.accumulated_continuous_time
      # 完成一轮参拜
      # 计算获得的奖品
      goods = get_reward_goods
      # 清零数据
      self.accumulated_continuous_time = 0
      if self.r_type == 3
        self.r_type = 6
      else
        self.r_type = 5
      end
      return false, [] unless self.save
    end
    return true, goods
  end

  private
  #
  # 获取物品列表
  #
  def get_reward_goods
    goods_config_array = []
    case self.r_type
      when 3
        goods_config_array = ZhangmenrenConfig.instance.market_config['canbai_1000']
      when 6
        goods_config_array = ZhangmenrenConfig.instance.market_config['canbai_2000']
      when 5
        goods_config_array = ZhangmenrenConfig.instance.market_config['canbai_3000']
    end
    rand_num = rand(100)
    logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) rand_num #{rand_num}.")
    sum = 0
    goods_config = nil
    goods_config_array.each do |goods|
      if rand_num <= sum
        goods_config = goods
        break
      end
      sum += (goods['probability'] * 100).to_i
      logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) sum #{sum}.")
    end

    unless goods_config.nil?
      logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) goods_config #{goods_config.to_json}.")
      # 在数据库中创建对应的物品
      goods_id = nil
      goods_type_id = nil
      case goods_config['type'].to_i
        when 2 # 武功
          gongfu = Gongfu.create_gongfu(self.user, goods_config['id'])
          if !gongfu.nil? && gongfu.save
            goods_id = gongfu.id
            goods_type_id = gongfu.gf_type
          end
        when 4 # 道具
          ug = UserGoods.new(user_id: user_id, g_type: goods_config['id'], number: goods_config['number'].to_i)
          if ug.save
            goods_id = ug.id
            goods_type_id = ug.g_type
          end
        when 6 # 弟子
          goods_id = nil
          goods_type_id = goods_config['id']
        when 7 # 魂魄
          soul = Soul.new(user_id: user_id, s_type: goods_config['id'], number: goods_config['number'].to_i)
          soul.potential = 0
          if soul.save
            goods_id = soul.id
            goods_type_id = soul.g_type
          end
        when 8 # 装备
          equ = Equipment.create_equipment(self.user, goods_config['id'])
          if !equ.nil? && equ.save
            goods_id = equ.id
            goods_type_id = equ.e_type
          end
      end

      tmp = {}
      tmp[:id] = goods_id
      tmp[:goods_type_id] = goods_type_id
      tmp[:type] = goods_config['type'].to_i
      tmp[:number] = goods_config['number'].to_i
      tmp[:type] = r_type.to_i
      tmp[:continuous_time] = accumulated_continuous_time
      tmp[:server_time] = URI.encode(Time.now.strftime('%F %T'))
      logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) goods #{tmp.to_json}.")
      return [tmp]
    else
      logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) no goods get???.")
    end
    []
  end

  #
  # 增加参拜次数
  #
  def increase_canbai_time
    if self.last_canbai_time == Time.now.to_date
      return false
    end
    # 判断上次参拜是否连续
    if self.last_canbai_time == Time.now.to_date.yesterday
      self.accumulated_continuous_time += 1
    else
      # 参拜不连续，从头开始
      self.accumulated_continuous_time = 1
    end
    self.last_canbai_time = Time.now.to_date

    recorder = CanbaiRecorder.new(canbai_at: Time.now, user_id: self.user_id)
    recorder.save && self.save
  end
end
