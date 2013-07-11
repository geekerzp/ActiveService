class LunjianPosition < ActiveRecord::Base
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
    tmp = {}
    tmp[:id] = self.id
    tmp[:position] = self.position
    tmp[:score] = self.score
    tmp[:left_time] = self.left_time
    tmp[:highest_position] = self.highest_position
    if self.user.nil?
      tmp[:user_info] = ''
    else
      tmp[:user_info] = self.user.to_dictionary
    end
    tmp
  end

  #
  # 获取列表
  #
  # @param [User] user 当前用户
  def self.get_list(user)
    list_printer = Proc.new do |m|
      logger.debug("### #{__method__},(#{__FILE__},#{__LINE__}) " <<
<<<<<<< HEAD
                   "id: #{m["id"]} position:#{m["position"]} user_id: #{m["user_info"]["id"]} " <<
                   "user_name:#{m["user_info"]["name"]}")
=======
                   "id: #{m[:id]} position:#{m[:position]} user_id: #{m[:user_info][:id]} " <<
                   "user_name:#{m[:user_info][:name]}")
>>>>>>> 1df712f1bd3ad39284bcc93c9ec041257e08933e
    end
    user_list = []

    if LunjianPosition.first.nil?
      init_pknpc()
    end

    # 排名前十的用户
    first_ten_users = LunjianPosition.order('position asc').offset(0).limit(10)
<<<<<<< HEAD

=======
>>>>>>> 1df712f1bd3ad39284bcc93c9ec041257e08933e
    first_ten_users.each() do |usr|
      tmp = usr.to_dictionary()
      tmp[:status] = LP_STATUS_SEE_TEAM
      user_list << tmp
<<<<<<< HEAD
	
    end
    # return user_list
    logger.debug("### #{__method__},(#{__FILE__},#{__LINE__}) top ten : ")
    #user_list.each(){|m| list_printer.call(m)}
=======
    end
    logger.debug("### #{__method__},(#{__FILE__},#{__LINE__}) top ten : ")
    user_list.each(){|m| list_printer.call(m)}
>>>>>>> 1df712f1bd3ad39284bcc93c9ec041257e08933e

    # 当前用户
    curr_user = LunjianPosition.find_by_user_id(user.id)
    if curr_user.nil?
      # 用户第一次进入论剑系统，创建对应的排名记录
      LunjianPosition.transaction() do
        position = LunjianPosition.lock.count()
        curr_user = LunjianPosition.new(position: position, score: 0, user_id: user.id, highest_position: position)
        if user.vip_level == 0
          curr_user.left_time = 5
        else
          curr_user.left_time = ZhangmenrenConfig.instance.vip_config[user.vip_level.to_s]['lunjian_time_per_day'].to_i
        end
        curr_user.save
        logger.debug("### #{__method__},(#{__FILE__},#{__LINE__}) create new lunjian position at #{position}.")
      end
    end

    # 最近击败过自己的玩家4名
    failed_recorders = LunjianRecorder.where(defender_id: user.id, who_win: LunjianRecorder::ATTACKER_WIN).
                                        order('created_at desc').offset(0).limit(4)
    failed_recorders.each() do |recorder|
      lp = LunjianPosition.find_by_user_id(recorder.attacker_id)
      next if lp.nil? || lp.position > curr_user.position     # 战胜过当前用户且排名比当前用户靠前。
      tmp = user_list.find{|x| x[:position] == lp.position}  # 这个用户排在前10
      unless tmp.nil?
        tmp[:status] = LP_STATUS_BEAT_BACK
        next
      end
      tmp = lp.to_dictionary()
      tmp[:status] = LP_STATUS_BEAT_BACK
      user_list << tmp
    end
    logger.debug("### #{__method__},(#{__FILE__},#{__LINE__}) beat me : ")
<<<<<<< HEAD
    #user_list.each(){|m| list_printer.call(m)}
=======
    user_list.each(){|m| list_printer.call(m)}
>>>>>>> 1df712f1bd3ad39284bcc93c9ec041257e08933e

    # 前5名玩家
    curr_user_position = curr_user.position
    before_5_users = LunjianPosition.get_before_5_user(curr_user_position)
    before_5_users.each() do |usr|
      tmp = user_list.find{|x| x[:position] == usr.position}
      unless tmp.nil?
        if tmp[:status] == LP_STATUS_SEE_TEAM
          tmp[:status] = LP_STATUS_ATTACK
        end
        next
      end
      tmp = usr.to_dictionary()
      tmp[:status] = LP_STATUS_ATTACK
      user_list << tmp
    end
    logger.debug("### #{__method__},(#{__FILE__},#{__LINE__}) before five : ")
<<<<<<< HEAD
    #user_list.each(){|m| list_printer.call(m)}
=======
    user_list.each(){|m| list_printer.call(m)}
>>>>>>> 1df712f1bd3ad39284bcc93c9ec041257e08933e

    # 当前用户
    tmp = user_list.find{|x| x[:position] == curr_user.position}
    if tmp.nil?
      tmp = curr_user.to_dictionary()
      tmp[:status] = LP_STATUS_NO_OPS
      user_list << tmp
    else
      tmp[:status] = LP_STATUS_NO_OPS
    end
    logger.debug("### #{__method__},(#{__FILE__},#{__LINE__}) me : ")
<<<<<<< HEAD
    #user_list.each(){|m| list_printer.call(m)}
=======
    user_list.each(){|m| list_printer.call(m)}
>>>>>>> 1df712f1bd3ad39284bcc93c9ec041257e08933e

    # 后5名玩家
    after_5_users = LunjianPosition.get_after_5_user(curr_user_position)
    after_5_users.each() do |usr|
      tmp = user_list.find{|x| x[:position] == usr.position}
      unless tmp.nil?
        tmp[:status] = LP_STATUS_NO_OPS
        next
      end
      tmp = usr.to_dictionary()
      tmp[:status] = LP_STATUS_NO_OPS
      user_list << tmp
    end
    logger.debug("### #{__method__},(#{__FILE__},#{__LINE__}) after 5 : ")
<<<<<<< HEAD
    #user_list.each(){|m| list_printer.call(m)}
=======
    user_list.each(){|m| list_printer.call(m)}
>>>>>>> 1df712f1bd3ad39284bcc93c9ec041257e08933e

    # 清理后面的用户
    user_list.each() do |x|
      if x[:position] > curr_user_position
        x[:status] = LP_STATUS_NO_OPS
      end
    end

    logger.debug("### #{__method__},(#{__FILE__},#{__LINE__}) return:  ")
<<<<<<< HEAD
    #user_list.each(){|m| list_printer.call(m)}


    #user_list << ZhangmenrenConfig.instance.npc_config[0]
=======
    user_list.each(){|m| list_printer.call(m)}
>>>>>>> 1df712f1bd3ad39284bcc93c9ec041257e08933e
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
      user_list = LunjianPosition.get_5_user() {|i| curr_user_position - (5 - i)}
    elsif curr_user_position <= 30    # 前三十名的用户
      user_list = LunjianPosition.get_5_user() {|i| curr_user_position - (10 - i * 2)}
    elsif curr_user_position <= 200   # 前两百名的用户
      user_list = LunjianPosition.get_5_user() {|i| curr_user_position - (15 - i * 3)}
    else                              # 其他用户
      user_list = LunjianPosition.get_5_user() {|i| (curr_user_position.to_f * (0.975 + i.to_f  * 0.005)).to_i}
    end
    user_list
  end

  #
  # 后面5个用户
  #
  def self.get_after_5_user(curr_user_position)
    if curr_user_position <= 10       # 前十名的用户
      user_list = LunjianPosition.get_5_user() {|i| curr_user_position + (i + 1)}
    elsif curr_user_position <= 30    # 前三十名的用户
      user_list = LunjianPosition.get_5_user() {|i| curr_user_position + ((i + 1) * 2)}
    elsif curr_user_position <= 200   # 前两百名的用户
      user_list = LunjianPosition.get_5_user() {|i| curr_user_position + ((i + 1) * 3)}
    else                              # 其他用户
      user_list = LunjianPosition.get_5_user() {|i| (curr_user_position.to_f * (1.005 + i.to_f  * 0.005)).to_i}
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
    LunjianPosition.transaction() do
      lp1 = LunjianPosition.lock.find_by_position(position1)
      lp2 = LunjianPosition.lock.find_by_position(position2)
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
  def self.update_result(id, user, position, is_win)
    score_array = ZhangmenrenConfig.instance.lunjian_config['score_array']
    user_position = LunjianPosition.find_by_user_id(user.id)
    return ResultCode::ERROR, LunjianPosition.get_list(user) if user_position.nil?
    lp2 = nil
    code = LunjianPosition.transaction() do
      lp1 = LunjianPosition.lock.find_by_user_id(user.id)
      lp2 = LunjianPosition.lock.find_by_id(id)
      if lp2.position != position
        next ResultCode::LUNJIAN_POSITION_CHANGE
      end

      if is_win == 1
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
      next ResultCode::OK
    end
    if code != ResultCode::OK
      return code, LunjianPosition.get_list(user)
    end
    # 创建一条挑战记录
    lr = LunjianRecorder.new
    lr.attacker_id = user.id
    lr.defender_id = lp2.user_id
    lr.who_win = is_win == 1 ? LunjianRecorder::ATTACKER_WIN : LunjianRecorder::DEFENDER_WIN
    unless lr.save
      logger.debug("### #{__method__},(#{__FILE__},#{__LINE__}) #{lr.errors.full_messages.join('; ')}")
    end
    return code, LunjianPosition.get_list(user)
  end
end
