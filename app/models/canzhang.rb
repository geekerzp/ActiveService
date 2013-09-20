# vi: set fileencoding=utf-8 :
require 'second_level_cache/second_level_cache'

class Canzhang < ActiveRecord::Base
  acts_as_cached(version: 1, expires_in: 1.week)  # 开启二级缓存

  attr_accessible :cz_type, :number, :user_id

  belongs_to :user

  validates :cz_type, :number, :user_id, :presence => true
  validates :number, :user_id, :numericality => {:greater_than => 0, :only_integer => true}

  def to_dictionary
    tmp               = {}
    tmp[:id]          = self.id
    tmp[:type]        = URI.encode(self.cz_type)
    tmp[:number]      = self.number
    tmp[:user_id]     = self.user_id
    tmp[:gongfu_type] = URI.encode(ZhangmenrenConfig.instance.canzhang_config[self.cz_type]['gongfu_id'])
    tmp
  end

  #
  # 获取拥有类型为type的残章的用户列表。随机三个。
  #
  # @param [User] user      当前用户
  # @param [String] type    残章类型
  # @param [Integer] limit  列表长度限制
  def self.get_list(user, type, limit)
    list = []
    # 首先从用户中选择。
    user_canzhang_list = Canzhang.where(cz_type: type).where("user_id != #{user.id} && number > 1").shuffle
    # 选择和用户等级相当的用户。最多相差10个等级
    user_canzhang_list.each() do |user_canzhang|
      canzhang_usr = user_canzhang.user
      level_offset = canzhang_usr.level - user.level
      level_offset = level_offset > 0 ? level_offset : -level_offset
      if level_offset < 10
        tmp = {}
        tmp[:id] = canzhang_usr.id
        tmp[:user_info] = canzhang_usr.to_dictionary
        list << tmp
      end
      return list if list.length >= limit
    end

    logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) generate some canzhang npcs.")
    # 拥有残章的用户不够客户端的需求。创建一些npc。
    canzhang_config_info = ZhangmenrenConfig.instance.canzhang_config[type.to_s]
    return [] if canzhang_config_info.nil?

    canzhang_quality = canzhang_config_info['quality'].to_i
    logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) canzhang quality: #{canzhang_quality}")

    npc_name_config = ZhangmenrenConfig.instance.name_config

    npc_team_config_info = ZhangmenrenConfig.instance.canzhang_npc_team_config[canzhang_quality]
    max_level = npc_team_config_info['max_level'].to_i
    min_level = npc_team_config_info['min_level'].to_i
    npc_team = npc_team_config_info['team']
    logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) select NPC team: #{npc_team_config_info.to_json.to_s}")
    (limit - list.length).times() do |i|
      # 构造npc
      npc_user = User.new
      npc_user.level = rand(max_level - min_level + 1) + min_level
      npc_user.id = -100    # npc的id统一为-100
      npc_user.name = npc_name_config[User.get_random_name].to_s
      npc_user.prestige = rand(100)
      npc_user.gold = rand(100)
      npc_user.silver = rand(100)
      team = []
      # 构造npc的弟子
      disciple_id = 1
      npc_team.each() do |disciple_quality|
        disciple_id += 1
        team << disciple_id
        disciple_type = Disciple.random_select_disciple(disciple_quality.to_i)
        disciple = Disciple.new
        disciple.id = disciple_id
        disciple.d_type = disciple_type
        disciple.level = rand(max_level - min_level + 1) + min_level
        logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) " <<
                              "select disciple: #{disciple_type} level #{disciple.level}")
        # 构造该弟子的武功
        gongfus_type_array = [] # 功夫类型数组
        # 天赋武功
        gongfus_type_array << ZhangmenrenConfig.instance.disciple_config[disciple_type]['origin_gongfu']
        disciple_gongfu_config = ZhangmenrenConfig.instance.canzhang_npc_disciple_gongfus_config[disciple_quality]
        disciple_gongfu_config['gongfus_array'][rand(disciple_gongfu_config['gongfus_array'].length)].each() do |q|
          logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) #{q.to_json.to_s}")
          gongfus_type_array << Gongfu.random_select_gongfu_of_quality(q.to_i)
        end
        gongfu_id = disciple_id * 100 + 10
        gongfu_position = 0
        gongfus_type_array.each() do |gongfu_type|
          logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__})select disciple gongfu: #{gongfu_type}")
          gongfu_id += 1
          gongfu = Gongfu.new
          gongfu.gf_type = gongfu_type
          gongfu.id = gongfu_id
          gongfu.is_origin = false
          gongfu.level = rand(max_level - min_level + 1) + min_level
          gongfu.disciple_id = disciple_id
          gongfu.position = gongfu_position
          gongfu.grow_probability = 0
          gongfu_position += 1
          disciple.gongfus << gongfu
          npc_user.gongfus << gongfu
        end

        # 构造装备
        disciple_equip_config = ZhangmenrenConfig.instance.canzhang_npc_disciple_equipments_config[disciple_quality]
        equip_id = disciple_id * 100 + 20
        equip_type = 1
        equipments_array = disciple_equip_config['equipments_array']
        equipments_array[rand(equipments_array.length)].each() do |equip_quality|
          equip = Equipment.new
          equip.id = equip_id
          equip.e_type = Equipment.rand_select_equipment_with_quality_and_type(equip_quality.to_i, equip_type)
          logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__})select disciple equipment: #{equip.e_type}")
          equip.disciple_id = disciple_id
          equip.level = rand(max_level - min_level + 1) + min_level
          equip.position = equip_id
          equip_id += 1
          equip_type += 1
          disciple.equipments << equip
          npc_user.equipments << equip
        end
        npc_user.disciples << disciple
      end
      tmp = {}
      tmp[:id] = npc_user.id
      tmp[:user_info] = npc_user.to_dictionary
      tmp[:user_info][:session_key] = nil
      tmp[:user_info][:team] = team
      list << tmp
    end
    list
  end

  #
  # 上传战斗结果
  #
  # @param [String] type      残章类型
  # @param [Integer] user_id  被抢夺的用户id
  # @param [Integer] is_win   是否胜利
  # @param [User] user        当前用户
  # @return [Canzhang]        如果抢夺成功，返回残章实例，否则nil
  def self.update_result(user, type, user_id, is_win)
    logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) type #{type} user_id: #{user_id} is_win: #{is_win}")
    # 战斗没有胜利，则直接返回
    return nil if is_win != 1

    cangzhang_config = ZhangmenrenConfig.instance.canzhang_config[type]
    return nil if cangzhang_config.nil?

    canzhang_quality = cangzhang_config['quality']
    return nil if canzhang_quality.nil?
    canzhang_quality = canzhang_quality.to_i
    logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) canzhang_quality #{canzhang_quality}")

    canzhang_probability = ZhangmenrenConfig.instance.canzhang_grab_probability_config[canzhang_quality]
    return nil if canzhang_probability.nil?

    # 根据抢夺概率是否夺得残章
    rand_num = rand(100)
    is_grab_canzheng = rand_num < (canzhang_probability * 100).to_i
    return nil unless is_grab_canzheng
    logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) is grab #{is_grab_canzheng}" <<
                     " rand number #{rand_num} probability: #{canzhang_probability}")

    if user_id != -100
      # 如果普通用户。需要判断用户是否有足够的残章。
      is_grab_canzheng = Canzhang.transaction() do
        canzhang = Canzhang.lock.find_by_cz_type_and_user_id(type, user_id)
        break false if canzhang.nil?
        break false if canzhang.number <= 1
        canzhang.number -= 1
        break false if canzhang.save
        break true
      end
    end
    if is_grab_canzheng
      cz = Canzhang.find_by_cz_type_and_user_id(type, user.id)
      if cz.nil?
        cz = Canzhang.new(cz_type: type, user_id: user.id, number: 0)
      end
      cz.number += 1
      unless cz.save
        logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) #{cz.errors.full_messages.join(';')}")
        return nil
      end
      logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) canzhang: #{cz.to_json.to_s}")
      return cz
    end
    nil
  end

  #
  # 更新残章数据
  #
  # @param [Array] canzhangs 残章数组
  def self.update_canzhangs(canzhangs)
    canzhangs.each() do |cz|
      canzhang = Canzhang.find_by_id(cz[:id])
      canzhang.number = cz[:number].to_i
      if canzhang.number == 0
        canzhang.destroy
      else
        canzhang.save
      end
    end
  end

  #
  #创建残章
  #
  def self.create_canzhang(cz_type,number,user_id)
    cangzhang_config = ZhangmenrenConfig.instance.canzhang_config[cz_type]
    return nil if cangzhang_config.nil?
    cz = Canzhang.find_by_cz_type_and_user_id(cz_type,user_id)
    if cz.nil?  
       cz = Canzhang.new(cz_type: cz_type, user_id: user_id, number: number)
    end
    cz.number +=1

    unless cz.save
      logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) #{cz.errors.full_messages.join(';')}")
      return nil
    end
    logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) canzhang: #{cz.to_json.to_s}")
    return cz
  end
end
