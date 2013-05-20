#encoding: utf-8
class Equipment < ActiveRecord::Base
  attr_accessible :e_type, :grow_strength, :level, :user_id, :position, :disciple_id

  belongs_to :disciple
  belongs_to :user

  validates :e_type, :grow_strength, :level, :user_id, :presence => true
  validates :e_type, :length => {:maximum => 250, :minimum => 1}

  validates :level, :user_id, :numericality => {:greater_than_or_equal_to => 0, :only_integer => true}
  validates :grow_strength, :numericality => {:greater_than_or_equal_to => 0}
  validates :disciple_id, :numericality => {:only_integer => true}
  validates :position, :numericality => {:only_integer => true}
  #
  # 将信息转化为字典形式
  #
  def to_dictionary()

    re = {}
    re[:id] = self.id
    re[:level] = self.level
    re[:disciple_id] = self.disciple_id
    re[:grow_strength] = self.grow_strength
    re[:position] = self.position
    re[:type] = URI.encode(self.e_type || '')
    re
  end

  #
  # 得到装备的详情。
  #
  def get_equipment_detail
    @equipment_config = ZhangmenrenConfig.instance.equipment_config
    @names_config = ZhangmenrenConfig.instance.name_config
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    re = {}
    re[:id] = self.id
    re[:level] = self.level
    re[:disciple_id] = self.disciple_id
    re[:grow_strength] = self.grow_strength
    re[:position] = self.position
    re[:type] = URI.encode(self.e_type || '')
    type = ""
    if @equipment_config[self.e_type]["type"] == 1
      type = "攻击"
    end
    if @equipment_config[self.e_type]["type"] == 2
      type = "防御"
    end
    if @equipment_config[self.e_type]["type"] == 3
      type = "坐骑"
    end
    re[:equipment_type] = type
    re[:equipment_name] = @names_config[@equipment_config[self.e_type]["name"]]
    disciple_id = self.disciple_id
    name = ""
    if disciple_id.nil? || disciple_id <= 0
      name = "未使用"
    else
      disciple = Disciple.find_by_id(disciple_id)
      name = "未使用" if disciple.nil?
      unless disciple.nil?
        name = @names_config[@disciple_config[disciple.d_type]["name"]]
      end
    end
    re[:disciple_id] = disciple_id
    re[:disciple_name] = name
    re
  end

  #
  # 更新装备信息
  #
  # @param [User] user              当前用户
  # @param [Array] equipment_array  装本信息数组
  def self.update_equipments(user, equipment_array)
    err_msg = ""
    equipment_array.each() do |equipment_info|
      id = equipment_info[:id]
      eq = Equipment.find_by_id_and_user_id(id, user.id)
      if eq.nil?
        logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__})no such equipment #{id}")
        next
      end
      eq.level = (equipment_info[:level] || 0).to_i
      eq.grow_strength = (equipment_info[:grow_strength] || 0).to_f
      #eq.position = (equipment_info[:position] || -1).to_i
      unless eq.save
        err_msg << eq.errors.full_messages.join('; ')
        logger.error("### #{__method__},(#{__FILE__}, #{__LINE__})save equipment error. #{err_msg}")
        return false, err_msg
      end
    end

    # 删除不存在的装备
    user.equipments.each() do |eq|
      if (equipment_array.find(){|e_info| e_info[:id].to_i == eq.id}).nil?
        eq.destroy
      end
    end
    return true, ''
  end

  #
  # 创建一个装备
  #
  # @param [User] user
  # @param [String] type
  def self.create_equipment(user, type)
    eq = Equipment.new
    eq.user_id = user.id
    eq.disciple_id = -1
    eq.e_type = type
    eq.grow_strength = 0
    eq.level = 1
    eq.position = -1
    eq
  end

  #
  # 随机选择一个品质为quality，类型为type的装备
  #
  # @param [Integer] quality  装备品质
  # @param [Integer] type     装备类型
  # @return [String]  装备id
  def self.rand_select_equipment_with_quality_and_type(quality, type)
    logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) quality #{quality} type #{type}")
    equipments = []
    ZhangmenrenConfig.instance.equipment_config.each() do |k, v|
      if v['quality'].to_i == quality && v['type'].to_i == type
        equipments << v['id']
      end
    end
    logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) equipments : #{equipments.to_json.to_s}")
    equipments[rand(equipments.length)] || ''
  end

  #
  # 更换装备
  #
  def change_position(id, fir_id, sec_id, thi_id, user_id)
    equipment = Equipment.find_by_id(id)
    fir_equip = Equipment.find_by_id(fir_id)
    sec_equip = Equipment.find_by_id(sec_id)
    thi_equip = Equipment.find_by_id(thi_id)

    position = -1
    disciple_id = -1
    unless equipment.position == -1
      if equipment.position == 0
        unless fir_equip.disciple_id == -1
          team_member = TeamMember.find_by_disciple_id_and_user_id(fir_equip.disciple_id, user_id)
          unless team_member.nil?
            if team_member.position != -1
              position = 0
              disciple_id = fir_equip.disciple_id
            end
          end
        end
      elsif equipment.position == 1
        unless sec_equip.disciple_id == -1
          team_member = TeamMember.find_by_disciple_id_and_user_id(sec_equip.disciple_id, user_id)
          unless team_member.nil?
            if team_member.position != -1
              position = 1
              disciple_id = sec_equip.disciple_id
            end
          end
        end
      elsif equipment.position == 2
        unless thi_equip.disciple_id == -1
          team_member = TeamMember.find_by_disciple_id_and_user_id(thi_equip.disciple_id, user_id )
          unless team_member.nil?
            if team_member.position != -1
              position = 2
              disciple_id = thi_equip.disciple_id
            end
          end
        end
      end
    end
    unless equipment.nil?
      equipment.update_attributes(position: position, disciple_id: disciple_id)
      equipment.save
    end
  end

  #
  # 根据装备类型得到装备名称
  #
  def change_type_to_name(equipment_type)
    @equipment_config = ZhangmenrenConfig.instance.equipment_config
    @names_config = ZhangmenrenConfig.instance.name_config
    equipment_name = ''
    equipment_name = @names_config[@equipment_config[equipment_type]["name"]]
    return equipment_name
  end

  #
  # 根据装备名称得到装备类型
  #
  def change_name_to_type(equipment_name)
    @equipment_config = ZhangmenrenConfig.instance.equipment_config
    @names_config = ZhangmenrenConfig.instance.name_config

    e_type = ''
    @names_config.keys.each() do |k|
      next unless @names_config[k] == equipment_name
      e_type = k
    end
    e_type
  end
end
