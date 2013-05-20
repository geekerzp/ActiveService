require 'comm'
include Comm
class ObtainDiscipleRecorder < ActiveRecord::Base
  attr_accessible :disciple_type, :od_type, :user_id, :is_use_gold

  # 获取弟子的范围
  OD_TYPE_1_IN_10     = 1 # 十里挑一
  OD_TYPE_1_IN_100    = 2 # 百里挑一
  OD_TYPE_1_IN_10000  = 3 # 万里挑一

  # 弟子种类
  DISCIPLE_PERSON = 1
  DISCIPLE_SOUL   = 2

  #
  # 获取弟子
  #
  # @param [User] user
  # @param [Integer] type
  # @return [String, Integer, Integer, Integer] 弟子类型，是否是魂魄，弟子id，天赋武功id
  def self.obtain(user, type)
    # 创建一个收徒记录
    odr = ObtainDiscipleRecorder.new
    odr.is_use_gold = false
    today_left_time = ObtainDiscipleRecorder.get_today_left_time(user, type)
    logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) today_left_time #{today_left_time}")

    if user.direction_step < 20
      disciples_for_freshman = %w(disciple_4314 disciple_4313 disciple_4312 disciple_4320 disciple_3311 \
                                  disciple_3310 disciple_2306 disciple_2305 disciple_1308 disciple_1307)
      # 第一次抽取，从指定的10个弟子中抽取，并且不为魂魄
      disciple_type = disciples_for_freshman[rand(10)]
      disciple_or_soul = DISCIPLE_PERSON
    else
      # 从掉落组里随机选择
      disciple_type, disciple_or_soul = ObtainDiscipleRecorder.obtain_disciple_from_drop_bag(type)
    end

    # 如果今天的剩余次数小于等于0，而客户端又调用了这个接口，说明是使用元宝购买的。
    if today_left_time <= 0 && user.direction_step >= 20
      odr.is_use_gold = true
      unless ObtainDiscipleRecorder.exists?(user_id: user.id, od_type: type, is_use_gold: true)
        logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) first use gold buy: #{type}")
        # 第一次使用元宝购买
        disciple_type = ObtainDiscipleRecorder.first_use_gold_obtain_disciple(type, user)
        disciple_or_soul = 1
      end
    end

    odr.disciple_type = disciple_type
    odr.od_type = type
    odr.user_id = user.id
    odr.disciple_or_soul = disciple_or_soul
    odr.save

    return disciple_type, disciple_or_soul, odr.is_use_gold
  end

  #
  # 首次使用元宝购买，获得顶配弟子。
  #
  # @param [User] user
  # @param [Integer] type
  def self.first_use_gold_obtain_disciple(type, user)
    disciple_quality = Disciple::DiscipleQualitySecond if type == OD_TYPE_1_IN_100
    disciple_quality = Disciple::DiscipleQualityFirst if type == OD_TYPE_1_IN_10000
    # 第一次使用元宝收徒，首刷得甲/乙
    disciple_id = Disciple.random_select_disciple(disciple_quality)
    while Disciple.exists?(user_id: user.id, d_type: disciple_id)
      disciple_id = Disciple.random_select_disciple(disciple_quality)
    end
    disciple_id
  end

  #
  # 从掉落组里随机获取弟子
  #
  # @param [Integer] type     收徒类型
  # @return [String, Integer] 弟子类型, 是否是魂魄
  def self.obtain_disciple_from_drop_bag(type)
    market_config = ZhangmenrenConfig.instance.market_config
    case type
      when OD_TYPE_1_IN_10
        group_probability_config = market_config['1_in_10_disciple_getting_probability']
      when OD_TYPE_1_IN_100
        group_probability_config = market_config['1_in_100_disciple_getting_probability']
      when OD_TYPE_1_IN_10000
        group_probability_config = market_config['1_in_10000_disciple_getting_probability']
      else
        group_probability_config = market_config['1_in_10_disciple_getting_probability']
    end

    bag_index = random_config(group_probability_config)
    bag_id = group_probability_config[bag_index]['drop_bag_id']
    bag_info = ZhangmenrenConfig.instance.random_drop_bags_config[bag_id]
    logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__})  bag_info #{bag_info.to_json}")

    # 从掉落组中选择弟子
    bag_content = bag_info['content']
    content_index = random_config(bag_content)
    disciple_id = bag_content[content_index]['id']
    disciple_or_soul = bag_content[content_index]['type'].to_i == 6 ? 1 : 2
    return disciple_id, disciple_or_soul
  end

  #
  # 计算今日此种类型的收徒剩余次数
  #
  # @param [User] user    用户
  # @param [Integer] type 收徒类型
  # @return [Integer]     收徒剩余次数
  def self.get_today_left_time(user, type)
    now_time = Time.now
    begin_time = Time.utc(now_time.year, now_time.month, now_time.day, 0, 0, 0)
    end_time = Time.utc(now_time.year, now_time.month, now_time.day, 23, 59, 59)
    logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) begin_time #{begin_time}, end_time #{end_time}")

    count = ObtainDiscipleRecorder.where(user_id: user.id, od_type: type).
                where('created_at >= ? and created_at <= ?', begin_time, end_time).count
    case type
      when OD_TYPE_1_IN_10
        left_time = 5 - count
      when OD_TYPE_1_IN_100
        left_time = 1 - count
      when OD_TYPE_1_IN_10000
        left_time = 1 - count
      else
        left_time = 0
    end
    left_time = left_time < 0 ? 0 : left_time
    left_time
  end

  #
  # 获取收徒记录列表
  #
  def self.get_recorders_list(user)
    list = []
    list << ObtainDiscipleRecorder.get_recorders_list_of_type(user, OD_TYPE_1_IN_10)
    list << ObtainDiscipleRecorder.get_recorders_list_of_type(user, OD_TYPE_1_IN_100)
    list << ObtainDiscipleRecorder.get_recorders_list_of_type(user, OD_TYPE_1_IN_10000)
    list
  end

  #
  # 获取此种类型的收徒记录
  #
  # @param [User] user    用户
  # @param [Integer] type 收徒类型
  def self.get_recorders_list_of_type(user, type)
    tmp = {}
    tmp[:od_type] = type
    tmp[:today_left_time] = ObtainDiscipleRecorder.get_today_left_time(user, type)
    tmp[:recorders] = []
    ObtainDiscipleRecorder.where(user_id: user.id, od_type: type).order("created_at desc").each() do |r|
      tmp[:recorders] << r.to_dictionary
    end
    tmp
  end

  def to_dictionary
    tmp = {}
    tmp[:id] = self.id
    tmp[:disciple_type] = URI.encode(self.disciple_type || '')
    tmp[:created_at] = URI.encode(self.created_at.to_s)
    tmp[:disciple_or_soul] = self.disciple_or_soul.to_i
    tmp[:is_use_gold] = self.is_use_gold
    tmp
  end
end
