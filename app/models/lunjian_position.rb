# vi: set fileencoding=utf-8 :
require 'second_level_cache/second_level_cache'

class LunjianPosition < ActiveRecord::Base
  acts_as_cached(version: 1, expires_in: 1.week)  # 开启二级缓存
  include Redis::Objects

  # 某个论剑位置详细信息的缓存
  value :cached_to_dictionary, marshal: true
  
  attr_accessible :left_time, :position, :score, :user_id, :highest_position

  belongs_to :user

  validates :left_time, :position, :score, :user_id, :presence => true
  validates :left_time, :user_id, :score, :numericality => { :greater_than_or_equal_to => 0,
                                                                      :only_integer => true }
  validates :position, :numericality => { :greater_than_or_equal_to => 1,
                                                 :only_integer => true }


  LP_STATUS_SEE_TEAM  = 1 # 前十的玩家，只能查看阵容
  LP_STATUS_BEAT_BACK = 2 # 击败过自己的玩家，反击
  LP_STATUS_ATTACK    = 3 # 前面的5位，挑战
  LP_STATUS_NO_OPS    = 4 # 后面的5位和用户自己，没有操作

  #
  # 生成20以内的数字，并转为字符串
  #
  def self.produce_random_str()
    num = rand(10000)%20 + 1
    if num < 10
      return '0' + num.to_s
    else
      return num.to_s
    end
  end

  #
  # 将user的信息转化为字典形式
  #
  def to_dictionary
    tmp                     = {}
    tmp[:id]                = self.id
    tmp[:position]          = self.position
    tmp[:score]             = self.score
    tmp[:left_time]         = self.left_time
    tmp[:highest_position]  = self.highest_position
    if self.user.nil?
      tmp[:user_info] = ''
    else
      re              = {}
      re[:id]         = self.user.id
      re[:name]       = URI.encode(self.user.name || '')
      re[:level]      = self.user.level
      re[:disciples]  = []
      re[:team]       = []
      re[:gongfus]    = []
      self.user.gongfus.each() {|v| re[:gongfus] << v.to_dictionary }
      re[:equipments] = []
      self.user.equipments.each()  {|v| re[:equipments] << v.to_dictionary }
      self.user.team_members.each do |v|
        unless v.position == -1
          re[:team] << v.disciple_id
          re[:disciples] << Disciple.find(v.disciple_id).to_dictionary
        end
      end
      tmp[:user_info] = re
    end
    tmp
  end

  #
  # 获取列表
  #
  # @param [User] user 当前用户
  #
  def self.get_list(user)
    # 轮奸列表
    user_list = []

    init_pknpc if LunjianPosition.first.nil?

    # 排名前十的用户
    # 从缓存中获取前十名
    # 若缓存中不存在或在读取中出现问题则在数据库中读取前十名
    @@lunjian_first_ten ||= Redis::List.new('lunjian_first_ten', marshal: true)
    if @@lunjian_first_ten.empty? 
      LunjianPosition.order('position asc').offset(0).limit(10).each do |lunjian_positon|
        @@lunjian_first_ten << lunjian_positon
      end 
    end 

    @@lunjian_first_ten.each do |usr|
      usr.cached_to_dictionary = usr.to_dictionary if usr.cached_to_dictionary.nil?
      tmp           = usr.cached_to_dictionary.get
      tmp[:status]  = LP_STATUS_SEE_TEAM
      user_list << tmp
    end 

    # 当前用户
    curr_user = LunjianPosition.find_by_user_id(user.id)
    if curr_user.nil?
      # 用户第一次进入论剑系统，创建对应的排名记录
      LunjianPosition.transaction do
        position  = LunjianPosition.all.lock(true).count  # transaction中可能产生幻读
        curr_user = LunjianPosition.new(position: position, score: 0, user_id: user.id, highest_position: position)
        if user.vip_level == 0
          curr_user.left_time = 5
        else
          curr_user.left_time = ZhangmenrenConfig.instance.vip_config[user.vip_level.to_s]['lunjian_time_per_day'].to_i
        end
        curr_user.save
        logger.debug("## #{__method__},(#{__FILE__},#{__LINE__}) create new lunjian position at #{position}.")
      end
    end

    # 最近击败过自己的玩家4名
    failed_recorders = LunjianRecorder.where(defender_id: user.id, who_win: LunjianRecorder::ATTACKER_WIN).
                                       order('created_at desc').offset(0).limit(4)
    failed_recorders.each do |recorder|
      lp = LunjianPosition.find_by_user_id(recorder.attacker_id)
      next if lp.nil? || lp.position > curr_user.position     # 战胜过当前用户且排名比当前用户靠前。
      tmp = user_list.find{|x| x[:position] == lp.position}   # 这个用户排在前10
      unless tmp.nil?
        tmp[:status] = LP_STATUS_BEAT_BACK
      end
      tmp = lp.to_dictionary()
      tmp[:status] = LP_STATUS_BEAT_BACK
      user_list << tmp
    end
    # 带有缓存版本
    #if user.lunjian_recorder_last_failed_recorders.empty?
    #  LunjianRecorder.where(defender_id: user.id, who_win: LunjianRecorder::ATTACKER_WIN).
    #                  order('created_at desc').offset(0).limit(4).each do |recorder|
    #    user.lunjian_recorder_last_failed_recorders << recorder
    #  end 
    #end 
    #user.lunjian_recorder_last_failed_recorders.each do |recorder|
    #    lp = LunjianPosition.find_by_user_id(recorder.attacker_id)
    #    next if lp.nil? || lp.position > curr_user.position       # 战胜过当前用户且排名比当前用户靠前。
    #    tmp = user_list.find {|x| x[:position] == lp.position }   # 这个用户排在前10
    #    unless tmp.nil?
    #      tmp[:status] = LP_STATUS_BEAT_BACK
    #      next 
    #    end 
    #    tmp = lp.to_dictionary
    #    tmp[:status] = LP_STATUS_BEAT_BACK
    #    user_list << tmp
    #  end 
    #end 

    # 前5名玩家
    curr_user_position = curr_user.position
    # 从缓存中读取前5名玩家
    # 若缓存中不存在或在读取中出现问题则在数据库中读取前十名
    if user.lunjian_position_before_5_users.empty?     
      LunjianPosition.get_before_5_user(curr_user_position).each do |position|
        user.lunjian_position_before_5_users << position
      end 
    end 

    user.lunjian_position_before_5_users.each do |usr|
      tmp = user_list.find {|x| x[:position] == usr.position }
      unless tmp.nil?
        if tmp[:status] == LP_STATUS_SEE_TEAM
          tmp[:status] = LP_STATUS_ATTACK
        end 
        next 
      end 
      usr.cached_to_dictionary = usr.to_dictionary if usr.cached_to_dictionary.nil?
      tmp = usr.cached_to_dictionary.get
      tmp[:status] = LP_STATUS_ATTACK
      user_list << tmp
    end 

    # 当前用户
    tmp = user_list.find{|x| x[:position] == curr_user.position}
    if tmp.nil?
      tmp = curr_user.to_dictionary
      tmp[:status] = LP_STATUS_NO_OPS
      user_list << tmp
    else
      tmp[:status] = LP_STATUS_NO_OPS
    end

    # 后5名玩家
    if user.lunjian_position_after_5_users.empty?
      LunjianPosition.get_after_5_user(curr_user_position).each do |position|
        user.lunjian_position_after_5_users << position
      end 
    end 

    user.lunjian_position_after_5_users.each do |usr|
      tmp = user_list.find {|x| x[:position] == usr.position }
      unless tmp.nil?
        tmp[:status] = LP_STATUS_NO_OPS
        next
      end 
      usr.cached_to_dictionary = usr.to_dictionary if usr.cached_to_dictionary.nil?
      tmp = usr.cached_to_dictionary.get
      tmp[:status] = LP_STATUS_NO_OPS
      user_list << tmp
    end 

    # 清理后面的用户
    user_list.each do |x|
      if x[:position] > curr_user_position
        x[:status] = LP_STATUS_NO_OPS
      end
    end

    user_list
  end

  #
  #当论剑系统第一次被使用时初始化NPC数据
  #
  def self.init_pknpc()
    lunjian_positon = 1
    ZhangmenrenConfig.instance.npc_config.each() do |npc|
      if(User.find_by_name(npc["name"].to_s).nil?)
      user = User.new
      user.username = npc["id"].to_s
      user.password = npc["id"].to_s
      logger.debug("username : #{user.name}")
      user.name = ZhangmenrenConfig.instance.name_config[npc['name'].to_s].to_s
     # user.name = npc["name"].to_s
      logger.debug("config name : #{npc["name"].to_s}")
      user.level = npc["level"].to_i
      logger.debug("config level : #{npc["level"]}")
      user.save
      user_id =user.id
      logger.debug("------------------------")
      logger.debug("user_id : #{user_id}")
      team_position = 0
      npc["team"].each() do |d|
        disciple = Disciple.new
        disciple.user_id = user_id
        disciple.level = d["level"].to_i
        disciple.d_type = d["id"].to_s
        disciple.save

        team = TeamMember.new
        team.user_id = user_id.to_i
        team.disciple_id = disciple.id.to_i
        team.position = team_position
        team.save

        team_position += 1
      end
      lunjian = LunjianPosition.new
      lunjian.user_id = user_id
      lunjian.score = 0
      lunjian.position = lunjian_positon
      lunjian.save

      lunjian_positon += 1
      end

    end
  end

  #
  # 前面的五个用户
  #
  def self.get_before_5_user(curr_user_position)
    if curr_user_position <= 10       # 前十名的用户
      user_list = LunjianPosition.get_5_user {|i| curr_user_position - (5 - i)}
    elsif curr_user_position <= 30    # 前三十名的用户
      user_list = LunjianPosition.get_5_user {|i| curr_user_position - (10 - i * 2)}
    elsif curr_user_position <= 200   # 前两百名的用户
      user_list = LunjianPosition.get_5_user {|i| curr_user_position - (15 - i * 3)}
    else                              # 其他用户
      user_list = LunjianPosition.get_5_user {|i| (curr_user_position.to_f * (0.975 + i.to_f  * 0.005)).to_i}
    end
    user_list
  end

  #
  # 后面5个用户
  #
  def self.get_after_5_user(curr_user_position)
    if curr_user_position <= 10       # 前十名的用户
      user_list = LunjianPosition.get_5_user {|i| curr_user_position + (i + 1)}
    elsif curr_user_position <= 30    # 前三十名的用户
      user_list = LunjianPosition.get_5_user {|i| curr_user_position + ((i + 1) * 2)}
    elsif curr_user_position <= 200   # 前两百名的用户
      user_list = LunjianPosition.get_5_user {|i| curr_user_position + ((i + 1) * 3)}
    else                              # 其他用户
      user_list = LunjianPosition.get_5_user {|i| (curr_user_position.to_f * (1.005 + i.to_f  * 0.005)).to_i}
    end
    user_list
  end

  #
  # 获取五个用户。由block产生position
  #
  def self.get_5_user()
    user_list = []
    5.times() do |i|
      position = yield(i)      # 通过block获取
      logger.debug("### #{__method__},(#{__FILE__},#{__LINE__}) get user at #{position}")
      tmp_user = LunjianPosition.find_by_position(position)
      user_list << tmp_user unless tmp_user.nil?
    end
    user_list
  end

  #
  # 锁定这两个用户
  #
  # @param [Integer] position1 位置1
  # @param [Integer] position2 位置2
  def self.lock_for_fight(position1, position2)
    LunjianPosition.transaction do
      lp1 = LunjianPosition.find_by_position(position1).lock(true)
      lp2 = LunjianPosition.find_by_position(position2).lock(true)
      return false if lp1.in_fighting || lp2.in_fighting
      lp1.in_fighting = true
      lp2.in_fighting = true
      lp1.save && lp2.save
    end
  end

  #
  # 更新战斗结果。同时解锁用户
  #
  # @param [User] user        发起挑战的用户
  # @param [Integer] id       挑战的位置的id
  # @param [Integer] position 挑战的位置
  # @param [Integer] is_win   是否胜利。1：胜利，0：失败
  #
  def self.update_result(id, user, position, is_win)
    score_array = ZhangmenrenConfig.instance.lunjian_config['score_array']
    user_position = LunjianPosition.find_by_user_id(user.id)
    return ResultCode::ERROR, LunjianPosition.get_list(user) if user_position.nil?

    lp2 = nil
    code = LunjianPosition.transaction do
      lp1 = LunjianPosition.find_by_user_id(user.id).lock(true)
      lp2 = LunjianPosition.find_by_id(id).lock(true)
      if lp2.position != position
        next ResultCode::LUNJIAN_POSITION_CHANGE
      end

      first_ten_update = false
      position_update = false
      if is_win == 1
        # 若比武胜利则用户的名次和被挑战者的名次都发生变化,
        # 用户和被挑战者的前后五名缓存用户要过期
        position_update = true
        # 若比武的两个玩家其中一个的名次在前十名内,
        # 则前十名发生变化,缓存要过期
        if lp1.position <= 10 || lp2.position <=10
          first_ten_update = true
        end
        # 挑战成功，交换位置
        tmp = lp1.position
        lp1.position = lp2.position
        lp2.position = tmp
        logger.debug("### #{__method__},(#{__FILE__},#{__LINE__}) exchange (#{lp1.position}, #{lp2.position})")
        lp1.highest_position = lp1.position if lp1.position < lp1.highest_position
        lp2.highest_position = lp2.position if lp2.position < lp2.highest_position
        # 挑战次数减一
        lp1.left_time = lp1.left_time - 1
        # 获得积分
        if lp1.position <= score_array.length
          lp1.score += score_array[lp1.position - 1].to_i
        else
          lp1.score += (300.to_f / Math.sqrt(lp1.position.to_f)).to_i;
        end
      end
      unless lp1.save && lp2.save
        err_msg = "#{lp1.errors.full_messages.join('; ')}"
        err_msg << "#{lp2.errors.full_messages.join('; ')}"
        logger.error("### #{__method__},(#{__FILE__},#{__LINE__}) #{err_msg}")
        next ResultCode::ERROR
      end

      # 前十名过期
      if first_ten_update
        @@lunjian_first_ten.each {|position| position.cached_to_dictionary.clear }
        @@lunjian_first_ten.clear
      end 

      # 用户和被挑战者前后五名玩家过期
      if position_update
        defender = User.find(lp2.user_id)   # 防御者
        defender.lunjian_position_before_5_users.each {|position| position.cached_to_dictionary.clear }
        defender.lunjian_position_before_5_users.clear; 
        defender.lunjian_position_after_5_users.each {|position| position.cached_to_dictionary.clear }
        defender.lunjian_position_after_5_users.clear;
        user.lunjian_position_before_5_users.each {|position| position.cached_to_dictionary.clear }
        user.lunjian_position_before_5_users.clear; 
        user.lunjian_position_after_5_users.each {|position| position.cached_to_dictionary.clear }
        user.lunjian_position_after_5_users.clear;
      end 

      next ResultCode::OK
    end
    if code != ResultCode::OK
      return code, LunjianPosition.get_list(user)
    end
    # 创建一条挑战记录
    lr              = LunjianRecorder.new
    lr.attacker_id  = user.id
    lr.defender_id  = lp2.user_id
    lr.who_win = is_win == 1 ? LunjianRecorder::ATTACKER_WIN : LunjianRecorder::DEFENDER_WIN
    unless lr.save
      logger.debug("### #{__method__},(#{__FILE__},#{__LINE__}) #{lr.errors.full_messages.join('; ')}")
    end
    return code, LunjianPosition.get_list(user)
  end
end
