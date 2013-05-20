class Disciple < ActiveRecord::Base
  attr_accessible :d_type, :experience, :grow_attack, :grow_blood, :grow_defend, :grow_internal, :level, :user_id
  attr_accessible :potential, :break_time

  has_many :equipments
  has_many :gongfus

  belongs_to :user

  validates :d_type, :experience, :grow_attack, :grow_blood, :grow_defend,
            :grow_internal, :level, :user_id, :break_time, :presence => true

  validates :d_type, :length => { :minimum => 1, :maximum => 250}
  validates :user_id, :experience, :break_time, :numericality => {:greater_than_or_equal_to => 0,
                                                                          :only_integer => true}
  validates :level, :numericality => {:greater_than_or_equal_to => 0, :less_than => 100,
                                      :only_integer => true}

  DiscipleQualityFirst   = 3     # 甲，紫色
  DiscipleQualitySecond  = 2     # 乙，蓝色
  DiscipleQualityThird   = 1     # 丙，绿色
  DiscipleQualityFourth  = 0     # 丁，白色


  def initialize
    super
    self.experience = 0
    self.grow_attack = 0.0
    self.grow_blood = 0.0
    self.grow_defend = 0.0
    self.grow_internal = 0.0
    self.break_time = 0
  end


  #
  # 将信息转化为字典形式
  #
  def to_dictionary()
    re = {}
    re[:id] = self.id
    re[:level] = self.level
    re[:experience] = self.experience
    re[:grow_attack] = self.grow_attack
    re[:grow_blood] = self.grow_blood
    re[:grow_defend] = self.grow_defend
    re[:grow_internal] = self.grow_internal
    re[:potential] = self.potential
    re[:break_time] = self.break_time
    re[:type] = URI.encode(self.d_type || '')

    re[:gongfus] = [-1, -1, -1]
    self.gongfus.each() {|gongfu| re[:gongfus][gongfu.position] = gongfu.id }

    re[:equipments] = [-1, -1, -1]
    self.equipments.each() {|equipment| re[:equipments][equipment.position] = equipment.id }
    re
  end

  #
  # 更新弟子信息
  #
  # @param [User] user            当前用户
  # @param [Array] disciple_array 弟子信息数组
  def self.update_disciples(user, disciple_array)
    err_msg = ""
    disciple_array.each() do |disciple_info|
      id = disciple_info[:id]
      disciple = Disciple.find_by_id_and_user_id(id, user.id)
      next if disciple.nil?
      disciple.level = (disciple_info[:level] || 0).to_i
      disciple.experience = (disciple_info[:experience] || 0).to_i
      disciple.grow_attack = (disciple_info[:grow_attack] || 0).to_f
      disciple.grow_blood = (disciple_info[:grow_blood] || 0).to_f
      disciple.grow_defend = (disciple_info[:grow_defend] || 0).to_f
      disciple.grow_internal = (disciple_info[:grow_internal] || 0).to_f

      disciple.potential = (disciple_info[:potential] || 0).to_i
      disciple.break_time = (disciple_info[:break_time] || 0).to_i

      # 更新武功
      gongfu_id_array = disciple_info[:gongfus]
      if gongfu_id_array.nil? || !gongfu_id_array.kind_of?(Array)
        logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) gongfus is not an array.")
      else
        disciple.update_gongfus_position(gongfu_id_array)
      end

      # 更新装备
      equipment_id_array = disciple_info[:equipments]
      if equipment_id_array.nil? || !equipment_id_array.kind_of?(Array)
        logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) equipments is not an array.")
      else
        disciple.update_equipments_position(equipment_id_array)
      end

      return false, err_msg << disciple.errors.full_messages.join(';') unless disciple.save
    end

    # 删除不存在的弟子
    user.disciples.each() do |disciple|
      if (disciple_array.find(){|d_info| d_info[:id].to_i == disciple.id}).nil?
        disciple.gongfus[0].destroy  # 删除天赋武功
        disciple.destroy
      end
    end
    return true, ''
  end

  #
  # 更新武功的位置
  #
  # @param [Array] gongfu_id_array 武功id数组
  def update_gongfus_position(gongfu_id_array)
    # 删除所有的弟子武功
    self.gongfus.each() do |gongfu|
      gongfu.disciple_id = -1
      gongfu.position = -1
      gongfu.save
    end
    # 添加新的弟子信息
    gongfu_id_array.each() do |id|
      gongfu = Gongfu.find_by_id_and_user_id(id, self.user_id)
      if gongfu.nil?
        logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) no such gongfu #{id}")
        next
      end
      gongfu.disciple_id = self.id
      gongfu.position = gongfu_id_array.find_index(id)
      if gongfu.position == 0   # 第一个是天赋武功。不能删除替换。
        gongfu.is_origin = true
      else
        gongfu.is_origin = false
      end
      unless gongfu.save
        logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) #{gongfu.errors.full_messages.join('; ')}")
      end
    end
  end

  #
  # 更新装备的位置
  #
  # @param [Array] equipment_id_array 装备id数组
  def update_equipments_position(equipment_id_array)
    self.equipments.each() do |e|
      e.disciple_id = -1
      e.position = -1
      e.save
    end

    equipment_id_array.each() do |id|
      eq = Equipment.find_by_id_and_user_id(id, self.user_id)
      if eq.nil?
        logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) no such equipment #{id}")
        next
      end
      eq.disciple_id = self.id
      eq.position = equipment_id_array.find_index(id)
      unless eq.save
        logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) #{eq.errors.full_messages.join('; ')}")
      end
    end
  end

  #
  # 添加装备
  #
  # @param [Equipment] equipment 添加的装备
  def add_equipment(equipment)
    return false if equipment.nil?
    return false if DiscipleEquipment.exists?(equipment_id: equipment.id)       # 已经装备了其他弟子
    return false if DiscipleEquipment.where(disciple_id: self.id).count() == 3  # 只能装备三个装备
    de = DiscipleEquipment.new
    de.disciple = self
    de.equipment = equipment
    de.save
  end

  #
  # 添加武功
  #
  # @param [Gongfu] gongfu
  def add_gongfu(gongfu)
    return false if gongfu.nil?
    return false if DiscipleGongfu.exists?(gongfu_id: gongfu.id)                # 已经装备了其他弟子
    return false if DiscipleGongfu.where(disciple_id: self.id).count() == 3     # 已经装备了3个武功
    dg = DiscipleGongfu.new
    dg.disciple = self
    dg.gongfu = gongfu
    dg.save
  end

  #
  # 为用户user创建一个type类型的弟子
  #
  # @param [User] user    用户
  # @param [String] type  弟子类型
  # @return [Disciple]    创建成功返回弟子实例，否则返回nil
  def self.create_disciple(user, type)
    # 如果用户已经有这样的弟子了，则不会再创建。
    if Disciple.exists?(d_type: type, user_id: user.id)
      logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) already have this disciple. #{type}")
      return nil
    end
    disciple = Disciple.new
    disciple_config = ZhangmenrenConfig.instance.disciple_config[type]
    # 找不到这样的弟子类型
    if disciple_config.nil?
      logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) no disciple config found. #{type}")
      return nil
    end

    logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) #{disciple_config.to_s}")

    disciple.d_type = type
    disciple.level = 1
    disciple.experience = 0
    disciple.user = user

    # 弟子保存失败
    unless disciple.save
      logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) #{disciple.errors.full_messages.join('; ')}")
      return nil
    end

    # 添加天生武功
    origin_gongfu = Gongfu.create_gongfu(user, disciple_config['origin_gongfu'])
    origin_gongfu.is_origin = true
    origin_gongfu.position = 0
    unless origin_gongfu.nil?
      disciple.gongfus << origin_gongfu
    end
    disciple
  end

  #
  # 随机抽取一个品质为quality的弟子
  #
  # @param [Integer] quality 弟子品质
  # @return [String] 弟子类型
  def self.random_select_disciple(quality)
    logger.error("### #{__method__},(#{__FILE__}, #{__LINE__})  #{quality}")
    disciple_configs = ZhangmenrenConfig.instance.disciple_config
    disciple_ids = []
    disciple_configs.each() do |k, v|
      if v['quality'].to_i == quality
        disciple_ids << k
      end
    end
    logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) disciple_ids: #{disciple_ids.to_json}")
    disciple_ids[rand(disciple_ids.length)]
  end
end
