#encoding: utf-8
require 'digest/sha2'
require 'digest/md5'
require 'comm'
require 'open-uri'
require 'json'
include Comm
class User < ActiveRecord::Base
  attr_accessible :password, :username, :name, :vip_level, :level, :prestige, :gold, :silver, :power
  attr_accessible :last_login_ip, :last_login_time, :experience, :sprite, :status, :session_key
  attr_accessible :direction_step, :npc_or_not, :upgrade_3_reward, :upgrade_5_reward
  attr_accessible :upgrade_10_reward, :upgrade_15_reward

  # 用户状态
  USER_STATUS_NORMAL   = 1  # 正常
  USER_STATUS_LOCKED   = 2  # 已锁定
  USER_STATUS_DELETED  = 3  # 已删除

  has_many :disciples, :dependent => :destroy
  has_many :gongfus, :dependent => :destroy
  has_many :equipments, :dependent => :destroy

  has_many :team_members, :dependent => :destroy, :order => 'position asc'

  has_many :zhangmenjues, :dependent => :destroy
  has_many :canzhangs, :dependent => :destroy

  has_many :souls, :dependent => :destroy
  has_many :pay_recorders, :dependent => :destroy
  has_many :user_goodss, :dependent => :destroy

  has_many :jianghu_recorders, :dependent => :destroy, :order =>'created_at desc' #'scene_id asc, item_id asc'

  has_many :lunjian_positions, :dependent => :destroy, :order => 'position asc'
  has_many :lunjian_recorders, :foreign_key => 'attacker_id', :dependent => :destroy

  has_many :lunjian_reward_recorders, :dependent => :destroy, :order => 'position asc'

  has_many :dianbos, :dependent => :destroy

  has_many :jiaohuaji_recorders, :dependent => :destroy

  has_one :canbai_reward_recorder, :dependent => :destroy
  has_many :canbai_recorders, :dependent => :destroy
  has_many :handbooks, :dependent => :destroy

  has_many :orders, :dependent => :destroy

  # 数据验证
  validates :password, :username, :presence => true, :length => {:maximum => 250, :minimum => 1}

  validates :name, :presence => true, :length => {:maximum => 20, :minimum => 2}

  validates :vip_level, :presence => true, :numericality => {:greater_than => 0, :less_than => 30}

  validates :level, :presence => true, :numericality => {:greater_than => 0, :less_than_or_equal_to => 100}

  validates :prestige, :gold, :silver, :power, :experience, :sprite, :presence => true
  validates :prestige, :gold, :silver, :power, :experience, :sprite, :numericality => {:greater_than_or_equal_to => 0}

  validates :status, :presence => true, :numericality => {:greater_than_or_equal_to => 1,
                                                          :less_than_or_equal_to => 3,
                                                          :only_integer => true}

  def initialize
    super
    self.name = 'no name'
    self.vip_level = 1
    self.level = 1
    self.prestige = 0
    self.gold = 0
    self.silver = 1000
    self.power = 20
    self.experience = 0
    self.sprite = 20
    self.status = USER_STATUS_NORMAL
    self.direction_step = 0
    self.upgrade_3_reward  = 0
    self.upgrade_5_reward  = 0
    self.upgrade_10_reward = 0
    self.upgrade_15_reward = 0
    self.npc_or_not = 0
  end

  #
  # 注册
  #
  # @param [String] username 用户名
  # @param [String] password 密码
  # @param request http请求
  # @return 结果码
  # @return 当创建成功时，创建的用户实例。否则是错误描述信息。
  def self.register(username, password, request)
    return ResultCode::REGISTERED_USERNAME, 'already registered username' if User.exists?(username: username)
    user = User.new
    user.username = username
    user.password = Digest::SHA2.hexdigest(password).to_s
    user.session_key = user.create_session_key
    user.last_login_ip = request.remote_ip
    user.last_login_time = Time.now
    user.npc_or_not = 0 # 注册用户不是npc

    continuous_login_reward = ContinuousLoginReward.new
    continuous_login_reward.user_id = user.id
    continuous_login_reward.continuous_login_time = 1 # 注册用户连续登陆次数设置为1
    continuous_login_reward.receive_or_not = 0
    login_reward_config = ZhangmenrenConfig.instance.login_reward_config
    reward_probability_config = login_reward_config['continuous_login_rewards']
    login_reward_index_1 = random_config(reward_probability_config)
    continuous_login_reward.reward_1_type = reward_probability_config[login_reward_index_1]['type'].to_i
    continuous_login_reward.reward_1_id = reward_probability_config[login_reward_index_1]['id']
    continuous_login_reward.reward_2_type = 0
    continuous_login_reward.reward_2_id = ''
    continuous_login_reward.reward_3_type = 0
    continuous_login_reward.reward_3_id = ''
    continuous_login_reward.save

    unless user.save
      unless user.errors['username'].nil?
        return ResultCode::INVALID_USERNAME, 'invalid username' << user.errors.full_messages.join('; ')
      end
      return ResultCode::ERROR, user.errors.full_messages.join('; ')
    end

    # 创建用户的掌门诀
    Zhangmenjue.new(user_id: user.id, z_type: Zhangmenjue::ZHANGMENJUE_TYPE_ATTACK, poli: 0, score:0, level: 0).save
    Zhangmenjue.new(user_id: user.id, z_type: Zhangmenjue::ZHANGMENJUE_TYPE_DEFEND, poli: 0, score:0, level: 0).save
    Zhangmenjue.new(user_id: user.id, z_type: Zhangmenjue::ZHANGMENJUE_TYPE_BLOOD, poli: 0, score:0, level: 0).save
    Zhangmenjue.new(user_id: user.id, z_type: Zhangmenjue::ZHANGMENJUE_TYPE_INTERNAL, poli: 0, score:0, level: 0).save
    return ResultCode::OK, user
  end

  #
  # 登录
  #
  # @param [String] username 用户名
  # @param [String] password 密码
  # @param request http请求
  # @return 结果码
  # @return 当登录成功时，是用户实例。否则是错误描述信息。
  def self.login(username, password, request)
    user = User.find_by_username_and_password(username, Digest::SHA2.hexdigest(password).to_s)
    unless user.nil?
      # 用户被锁定
      return ResultCode::USER_LOCKED, 'user is locked'  if user.status == USER_STATUS_LOCKED
      # 用户已经被删除
      if user.status == USER_STATUS_DELETED
        return ResultCode::INVALID_USERNAME_PASSWORD, 'invalid username or password'
      end

      user.session_key = user.create_session_key
      user.last_login_ip = request.remote_ip

      # 部分注册用户是直接通过数据库添加的，last_login_time可能为nil，考虑为空的情况。
      if user.last_login_time.nil?
        user.last_login_time = Time.now
      end

      # 导入连续登陆配置信息
      login_reward_config = ZhangmenrenConfig.instance.login_reward_config
      reward_probability_config = login_reward_config['continuous_login_rewards']

      # 修改连续登录次数及其奖励
      day_offset = Time.now.day - user.last_login_time.day
      continuous_login_reward = ContinuousLoginReward.find_by_user_id(user.id)
      if continuous_login_reward.nil?
        continuous_login_reward = ContinuousLoginReward.new
        continuous_login_reward.user_id = user.id
        continuous_login_reward.continuous_login_time = 1 # 初始化用户连续登陆次数设置为1
        continuous_login_reward.receive_or_not = 0

        login_reward_index_1 = random_config(reward_probability_config)
        continuous_login_reward.reward_1_type = reward_probability_config[login_reward_index_1]['type'].to_i
        continuous_login_reward.reward_1_id = reward_probability_config[login_reward_index_1]['id']
        continuous_login_reward.reward_2_type = 0
        continuous_login_reward.reward_2_id = ''
        continuous_login_reward.reward_3_type = 0
        continuous_login_reward.reward_3_id = ''
      else
        if day_offset > 1
          # 如果登陆天数相差两天或以上，则将连续登陆次数设置为1
          continuous_login_reward.continuous_login_time = 1
          # 更新连续登陆奖励
          continuous_login_reward.receive_or_not = 0
          login_reward_index_1 = random_config(reward_probability_config)
          continuous_login_reward.reward_1_type = reward_probability_config[login_reward_index_1]['type'].to_i
          continuous_login_reward.reward_1_id = reward_probability_config[login_reward_index_1]['id']
          continuous_login_reward.reward_2_type = 0
          continuous_login_reward.reward_2_id = ''
          continuous_login_reward.reward_3_type = 0
          continuous_login_reward.reward_3_id = ''
        elsif day_offset == 1
          # 如果登陆天数相差一天，则将连续登陆次数+1；如果已经为3，则不变。
          if continuous_login_reward.continuous_login_time < 3
            continuous_login_reward.continuous_login_time = continuous_login_reward.continuous_login_time + 1
          end
          # 更新连续登陆奖励
          continuous_login_reward.receive_or_not = 0
          if continuous_login_reward.continuous_login_time == 1
            login_reward_index_1 = random_config(reward_probability_config)
            continuous_login_reward.reward_1_type = reward_probability_config[login_reward_index_1]['type'].to_i
            continuous_login_reward.reward_1_id = reward_probability_config[login_reward_index_1]['id']
            continuous_login_reward.reward_2_type = 0
            continuous_login_reward.reward_2_id = ''
            continuous_login_reward.reward_3_type = 0
            continuous_login_reward.reward_3_id = ''
          elsif continuous_login_reward.continuous_login_time == 2
            login_reward_index_1 = random_config(reward_probability_config)
            continuous_login_reward.reward_1_type = reward_probability_config[login_reward_index_1]['type'].to_i
            continuous_login_reward.reward_1_id = reward_probability_config[login_reward_index_1]['id']

            # 奖励2不能和奖励1相同
            login_reward_index_2 = random_config(reward_probability_config)
            while login_reward_index_2 == login_reward_index_1 do
              login_reward_index_2 = random_config(reward_probability_config)
            end
            continuous_login_reward.reward_2_type = reward_probability_config[login_reward_index_2]['type'].to_i
            continuous_login_reward.reward_2_id = reward_probability_config[login_reward_index_2]['id']

            # 奖励3为空
            continuous_login_reward.reward_3_type = 0
            continuous_login_reward.reward_3_id = ''
          elsif continuous_login_reward.continuous_login_time == 3
            login_reward_index_1 = random_config(reward_probability_config)
            continuous_login_reward.reward_1_type = reward_probability_config[login_reward_index_1]['type'].to_i
            continuous_login_reward.reward_1_id = reward_probability_config[login_reward_index_1]['id']

            # 奖励2不能和奖励1相同
            login_reward_index_2 = random_config(reward_probability_config)
            while login_reward_index_2 == login_reward_index_1 do
              login_reward_index_2 = random_config(reward_probability_config)
            end
            continuous_login_reward.reward_2_type = reward_probability_config[login_reward_index_2]['type'].to_i
            continuous_login_reward.reward_2_id = reward_probability_config[login_reward_index_2]['id']

            # 奖励3不能和奖励2相同，也不能和奖励2相同
            login_reward_index_3 = random_config(reward_probability_config)
            while login_reward_index_3 == login_reward_index_1 || login_reward_index_3 == login_reward_index_2 do
              login_reward_index_3 = random_config(reward_probability_config)
            end
            continuous_login_reward.reward_3_type = reward_probability_config[login_reward_index_3]['type'].to_i
            continuous_login_reward.reward_3_id = reward_probability_config[login_reward_index_3]['id']
          else
            # 连续登陆次数不可能超过3次
          end
        else
          # 在同一天内的登陆不会更新奖励配置
        end
      end

      user.last_login_time = Time.now
      unless user.save && continuous_login_reward.save
        return ResultCode::ERROR, 'login failed'
      end
      return ResultCode::OK, user, continuous_login_reward
    end
    return ResultCode::INVALID_USERNAME_PASSWORD, 'invalid username or password'
  end

  def self.login_from_91server(uin,sessionId,request)
    act = 4
    url91 = "http://service.sj.91.com/usercenter/ap.aspx"

    # 参数错误
    if uin.nil? and sessionId.nil?
      return ResultCode::ERROR , "invalid parameters"
    # 第一次以后从91登录
    elsif sessionId.empty?
      return User.login(uin, USER_DEFAULT_PWD, request)
    # 第一次从91登录
    else
      sign = Digest::MD5.hexdigest(APPID + act.to_s + uin + sessionId + APPKEY)

      source_str ||= "?AppId=" + APPID + "&Act=" + act.to_s + "&Uin=" + uin + "&SessionId=" + sessionId + "&Sign=" +sign
      url = url91 << source_str

      response = nil
      open(url) do |http|
        response = http.read
      end

      if response.nil?
        return ResultCode::ERROR, "no response"
      end

      data = JSON URI.decode(response)
      if(!data["ErrorCode"].eql?(1.to_s))
        return ResultCode::ERROR , data["ErrorDesc"]
      end

      user = User.find_by_username(uin)
      if user.nil?
        return User.register(uin,USER_DEFAULT_PWD,request)
      end

      return User.login(uin,USER_DEFAULT_PWD,request)
    end
  end
  #
  # 将user的信息转化为字典形式
  #
  def to_dictionary
    re = {}
    re[:id] = self.id
    re[:session_key] = URI.encode(self.session_key || '')
    re[:username] = URI.encode(self.username || '')
    re[:name] = URI.encode(self.name || '')
    re[:vip_level] = self.vip_level
    re[:level] = self.level
    re[:prestige] = self.prestige
    re[:gold] = self.gold
    re[:silver] = self.silver
    re[:power] = self.power
    re[:experience] = self.experience
    re[:sprite] = self.sprite
    re[:direction_step] = self.direction_step
    re[:upgrade_3_reward] = self.upgrade_3_reward
    re[:upgrade_5_reward] = self.upgrade_5_reward
    re[:upgrade_10_reward] = self.upgrade_10_reward
    re[:upgrade_15_reward] = self.upgrade_15_reward
    re[:gongfus] = []
    self.gongfus.each() {|v| re[:gongfus] << v.to_dictionary }
    re[:disciples] = []
    self.disciples.each() {|v| re[:disciples] << v.to_dictionary }
    re[:equipments] = []
    self.equipments.each() {|v| re[:equipments] << v.to_dictionary }
    re[:souls] = []
    self.souls.each() {|v| re[:souls] << v.to_dictionary }
    re[:zhangmenjues] = []
    self.zhangmenjues.each() {|v| re[:zhangmenjues] << v.to_dictionary }
    re[:goods] = []
    self.user_goodss.each() {|goods| re[:goods] << goods.to_dictionary}
    re[:team] = []
    self.team_members.each() {|tm| re[:team] << tm.disciple_id}

    re[:lunjian_time] = 5
    re[:lunjian_score] = 0
    lp = LunjianPosition.find_by_user_id(self.id)
    unless lp.nil?
      re[:lunjian_time] =lp.left_time
      re[:lunjian_score] =lp.score
    end
    re
  end

  #
  # 创建session key
  #
  def create_session_key
    tmp = ""
    tmp << username
    tmp << password
    tmp << Time.now.to_s
    tmp << rand(100000).to_s
    Digest::SHA2.hexdigest(tmp).to_s
  end

  #
  # 获取用户的江湖记录
  #
  def get_jianghu_recorders
    self.jianghu_recorders.map() {|r| r.to_dictionary }
  end

  #
  # 更新用户信息
  #
  # @param [String] name 门派名称
  # @param [Hash] params 用户信息
  def update_info(name, params)
    self.name = name
    self.vip_level = (params[:vip_level] || self.vip_level).to_i
    self.level = (params[:level] || self.level).to_i
    self.prestige = (params[:prestige] || self.prestige).to_i
    self.gold = (params[:gold] || self.gold).to_i
    self.silver = (params[:silver] || self.silver).to_i
    self.power = (params[:power] || self.power).to_i
    self.experience = (params[:experience] || self.experience).to_i
    self.sprite = (params[:sprite] || self.sprite).to_i

    lp = LunjianPosition.find_by_user_id(self.id)
    unless lp.nil?
      lp.left_time = (params[:lunjian_time] || lp.left_time).to_i
      lp.score = (params[:lunjian_score] || lp.score).to_i
      lp.save
    end

    self.save
  end

  def self.get_random_name
    "name#{rand(100).to_s}"
  end

  #
  # 更新用户门派信息
  #
  # @param [String] name 门派名称
  def update_zhangmen_name(name)
    self.name = name
    self.save
  end

  #
  # 更新用户元宝数
  # @param [Integer] gold  元宝数
  #
  def update_gold(gold)
    self.gold = gold
    self.save
  end


  #
  # 得到用户已有的物品
  #
  def get_user_goods(user_id)
    user = User.find_by_id(user_id)
    user_goods_list = []
    unless user.nil?
      user_goods = user.user_goodss
      unless user_goods.nil?
        user_goods.each() do|g|
          user_goods_list << g.g_type
        end
      end
    end
    user_goods_list
  end

  #
  # 得到用户已有的魂魄
  #
  def get_user_souls(user_id)
    user = User.find_by_id(user_id)
    user_souls_list = []
    unless user.nil?
      user_souls = user.souls
      unless user_souls.nil?
        user_souls.each() do|s|
          user_souls_list << s.s_type
        end
      end
    end
    user_souls_list
  end

  #
  # 获取用户的残章类型
  #
  def get_user_canzhang_types(user_id)
    user = User.find_by_id(user_id)
    user_canzhang_types_list = []
    unless user.nil?
      user_canzhangs = user.canzhangs
      user_canzhangs.each() do |cz|
        user_canzhang_types_list << cz.cz_type
      end
    end
    logger.debug{"user_canzhang_types_list = #{user_canzhang_types_list}"}
    user_canzhang_types_list
  end


  #
  # 获取用户战斗信息(传书)
  # @param [User] user 用户
  def self.get_fight_messages(user)
    messages_array = []

    # 获取论剑被挑战信息
    defend_messages = LunjianRecorder.get_defend_messages(user.id)
    defend_messages.each do |defend_message|
      messages_array << defend_message
    end

    # 被夺残章信息
    grab_messages = CanzhangGrabRecorder.get_grabbed_messages(user.id)
    grab_messages.each do |grab_message|
      messages_array << grab_message
    end

    return self.sort_time_desc(messages_array)
  end

  #
  # 获取用户全部信息(传书)
  # @param [User] user 用户
  def self.get_all_messages(user)
    messages_array = []

    # 获取论剑被挑战信息
    defend_messages = LunjianRecorder.get_defend_messages(user.id)
    defend_messages.each do |defend_message|
      messages_array << defend_message
    end

    # 被夺残章信息
    grab_messages = CanzhangGrabRecorder.get_grabbed_messages(user.id)
    grab_messages.each do |grab_message|
      messages_array << grab_message
    end

    # 好友留言信息
    leave_messages = Message.get_leave_messages(user.id)
    leave_messages.each do |leave_message|
      messages_array << leave_message
    end

    # 好友申请信息
    apply_messages = FriendApplyRecorder.get_apply_messages(user.id)
    apply_messages.each do |apply_message|
      messages_array << apply_message
    end

    # 申请好友反馈信息
    apply_feedback_messages = FriendApplyRecorder.get_feedback_messages(user.id)
    apply_feedback_messages.each do |apply_feedback_message|
      messages_array << apply_feedback_message
    end

    # 系统消息
    system_messages = SystemRewardRecorder.get_system_messages(user.id)
    system_messages.each do |system_message|
      messages_array << system_message
    end

    return sort_time_desc(messages_array)
  end

  #
  # 根据用户等级进行搜索
  # @param [integer] search_word
  # @return [Array] users_array 数组
  def self.get_user_list_by_level(search_word)
    # 返回的用户列表不能是npc
    return User.where('level = ? AND npc_or_not = ?', search_word, 0).order('last_login_time desc').limit(10)
  end

  #
  # 根据用户门派进行搜索
  # @param [string] search_word
  # @return [Array] users_array 数组
  def self.get_user_list_by_name(search_word)
    # 返回的用户列表不能是npc
    return User.where('name like ? AND npc_or_not = ?', "%#{search_word}%", 0).order('last_login_time desc').limit(10)
  end


end
