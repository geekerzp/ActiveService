# vi: set fileencoding=utf-8 :
require 'second_level_cache/second_level_cache'
require 'trigger'

class Gongfu < ActiveRecord::Base
  acts_as_cached(version: 1, expires_in: 1.week)  # 开启二级缓存

  attr_accessible :gf_type, :grow_strength, :level, :user_id, :position, :grow_probability, :disciple_id
  attr_accessible :is_origin, :experience

  belongs_to :disciple
  belongs_to :user

  validates :gf_type, :grow_strength, :level, :user_id, :presence => true
  validates :gf_type, :length => {:maximum => 250, :minimum => 1}
  validates :level, :user_id, :experience, :numericality => {:greater_than_or_equal_to => 0, :only_integer => true}
  validates :disciple_id, :numericality => {:greater_than_or_equal_to => -1, :only_integer => true}
  validates :grow_strength, :numericality => {:greater_than_or_equal_to => 0}

  #
  # 将信息转化为字典形式
  #
  def to_dictionary
    inspect
  end

  #
  # 获取功夫的详情
  #
  def get_gongfu_details
    re = inspect

    @gongfu_config    = ZhangmenrenConfig.instance.gongfu_config
    @disciple_config  = ZhangmenrenConfig.instance.disciple_config
    @names_config     = ZhangmenrenConfig.instance.name_config
    re[:gongfu_name]  = @names_config[@gongfu_config[self.gf_type]["name"]]
    disciple_name     = ''
    disciple = Disciple.find_by_id(self.disciple_id)
    if disciple.nil?
      disciple_name = '未使用'
    else
      disciple_name = @names_config[@disciple_config[disciple.d_type]["name"]]
    end
    re[:disciple_id] = self.disciple_id
    re[:disciple_name] = disciple_name
    re
  end

  #
  # 更新武功信息
  #
  # @param [User] user            当前用户
  # @param [Array] gongfus_array  功夫信息数组
  def self.update_gongfus(user, gongfus_array)
    err_msg = ""
    gongfus_array.each do |gongfu_info|
      id = gongfu_info[:id]
      gf = Gongfu.find_by_id_and_user_id(id, user.id)
      if gf.nil?
        logger.debug("### no such gongfu #{id}")
        next
      end

      # FIXME 武功装备升级强化事件
      today_first_strength = (gf.level < gongfu_info[:level]) && 
                                (gf.strengthened_token != Time.now.to_date.to_s)
      if today_first_strength 
        gf.strengthened_token = Time.now.to_date.to_s
        Trigger.rule_5(user, gf.gf_type)
      end 

      gf.level            = (gongfu_info[:level] || 0).to_i
      gf.grow_strength    = (gongfu_info[:grow_strength] || 0).to_f
      gf.grow_probability = (gongfu_info[:grow_probability] || 0).to_f
      gf.is_origin        = !(gongfu_info[:is_origin].nil? || gongfu_info[:is_origin].to_i == 0)
      gf.experience       = (gongfu_info[:experience] || 0).to_i
      #gf.position = (gongfu_info[:position] || -1).to_i
      unless gf.save
        err_msg << gf.errors.full_messages.join('; ')
        logger.error("### save gongfu error. #{err_msg}")
        return false, err_msg
      end
    end
    # 删除不存在的武功
    user.gongfus.each do |eq|
      if (gongfus_array.find {|e_info| e_info[:id].to_i == eq.id}).nil?
        eq.destroy
      end
    end
    return true, ''
  end

  #
  # 为user创建一个type类型的武功
  #
  # @param [User] user    用户
  # @param [String] type  武功类型
  def self.create_gongfu(user, type)
    type ||= ''
    logger.debug("### #{__method__} (#{__FILE__},#{__LINE__}) type: #{type}")
    gongfu = Gongfu.new
    gongfu_config = ZhangmenrenConfig.instance.gongfu_config[type]
    if gongfu_config.nil?
      logger.debug("### #{__method__} (#{__FILE__},#{__LINE__}) no such gongfu #{type}")
      return nil
    end
    #不同功夫的经验
    experiences = [80,20,30,40]

    gongfu.gf_type  = type
    gongfu.user     = user
    gongfu.position = -1
    gongfu.grow_probability = 0
    gongfu.grow_strength    = 0
    gongfu.level            = 1
    gongfu.disciple_id      = -1
    gongfu.experience       = experiences[gongfu_config["quality"].to_i]
    unless gongfu.save
      logger.error("### #{__method__} (#{__FILE__},#{__LINE__})  #{gongfu.errors.full_messages.join('; ')}")
      return nil
    end

    # FIXME 开箱获得道具事件
    Trigger.rule_3(user, type)

    # FIXME 收集残章获得新武功事件
    Trigger.rule_4(user, type)
    gongfu
  end

  #
  # 随机选择一个品质为quality的武功
  #
  # @param [Integer] quality 武功品质
  # @return [String]  武功类型
  def self.random_select_gongfu_of_quality(quality)
    gongfus = []
    ZhangmenrenConfig.instance.gongfu_config.each() do |k, v|
      if v['quality'].to_i == quality
        gongfus << v['id']
      end
    end
    gongfus[rand(gongfus.length)]
  end

  #
  # 更改弟子功夫
  #
  def change_position(id, sec_id, thi_id, user_id)
    gongfu = Gongfu.find_by_id(id)
    sec_gf = Gongfu.find_by_id(sec_id)
    thi_gf = Gongfu.find_by_id(thi_id)

    disciple_id = -1
    position = 0
    unless gongfu.position == -1
      if gongfu.position == 1
        unless sec_gf.disciple_id == -1
          team_member = TeamMember.find_by_disciple_id_and_user_id(sec_gf.disciple_id, user_id)
          unless team_member.nil?
            if team_member.position != -1
              position = 1
              disciple_id = sec_gf.disciple_id
            end
          end
        end
      elsif gongfu.position == 2
        unless thi_gf.disciple_id == -1
          team_member = TeamMember.find_by_disciple_id_and_user_id(thi_gf.disciple_id, user_id )
          unless team_member.nil?
            if team_member.position != -1
              position = 2
              disciple_id = thi_gf.disciple_id
            end
          end
        end
      end
    end
    unless gongfu.nil?
      gongfu.update_attributes(position: position, disciple_id: disciple_id)
      gongfu.save
    end

  end

  #
  # 根据武功类型得到武功名称
  #
  def change_type_to_name(gf_type)
    @gf_config    = ZhangmenrenConfig.instance.gongfu_config
    @names_config = ZhangmenrenConfig.instance.name_config

    gf_name = ''
    gf_name = @names_config[@gf_config[gf_type]["name"]]
    gf_name
  end

  #
  # 根据武功名称得到武功类型
  #
  def change_name_to_type(gf_name)
    @gf_config    = ZhangmenrenConfig.instance.gongfu_config
    @names_config = ZhangmenrenConfig.instance.name_config

    gf_type = ''
    @names_config.keys.each do |k|
      next unless @names_config[k] == gf_name
      gf_type = k
    end
    gf_type
  end

  #
  # 获取对象内部数据
  #
  def inspect 
    re                  = {}
    re[:id]             = self.id
    re[:level]          = self.level
    re[:grow_strength]  = self.grow_strength
    re[:position]       = self.position
    re[:disciple_id]      = self.disciple_id
    re[:grow_probability] = self.grow_probability
    re[:type]             = URI.encode(self.gf_type || '')
    re[:is_origin]        = self.is_origin ? 1 : 0
    re[:experience]       = self.experience
    re
  end 
end
