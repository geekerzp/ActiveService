#encoding: utf-8
require 'harmonious_dictionary'
module UserHelper
  @@n_symbol = ['~', '!','@','#','$','%','^','&','*','(',')','_','=','+','\\','|','[',']','{','}',':',';','"','\'',\
  '<','>',',','.','?','/','。','，','；','：','‘','“','”','-','【','】','\-'].join('')
  #
  # 注册接口
  #
  def register
    username = get_params(params, :username)
    password = get_params(params, :password)

    code, user = User.register(username, password, self)
    if code == ResultCode::OK
     return render_result(code, user.to_dictionary)
    end
     return render_result(code, {err_msg: URI.encode(user.to_s)})
  end

  #
  #登录接口
  #
  def login
    login_type = get_params(params,:login_type)  #true =>login from 91, false => login from appServer
    logger.debug("## file:#{__FILE__}, method:#{__method__},")
    # 91登录
    if login_type.to_i == 1
      logger.info("### login from 91")
      uin = get_params(params, :uin)
      sessionId= get_params(params,:sessionId)
      code ,user,continuous_login_reward = User.login_from_91server(uin,sessionId,self)
      # 直接登录
    else
      logger.info("### login directly")
      username = get_params(params, :username)
      password = get_params(params, :password)
      code ,user,continuous_login_reward = User.login(username,password,request)
    end

    if code == ResultCode::OK
      return_hash = {}
      if(!continuous_login_reward.nil?)
        return_hash[:continuous_login_reward] = continuous_login_reward.to_dictionary
      end
      return_hash[:user] = user.to_dictionary
      return render_result(code, return_hash)
    end
    return render_result(code, {err_msg: URI.encode(user.to_s)})

  end

  #
  # 用户获取登陆奖励
  #
    def receive_login_reward
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    continuous_login_reward = ContinuousLoginReward.find_by_user_id(user.id)
    continuous_login_reward.receive_or_not = ContinuousLoginReward::RECEIVED
    if continuous_login_reward.save
      render_result(ResultCode::OK, {})
    else
      render_result(ResultCode::SAVE_FAILED, {err_msg: 'save failed.'})
    end
  end

  #
  # 获取用户信息
  #
  def get_user_info
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    target_user = user
    user_id = params[:user_id]
    unless user_id.nil?
      target_user = User.find_by_id(user_id)
    end

    if target_user.nil?
      return render_result(ResultCode::NO_SUCH_USER, {err_msg: URI.encode("no such user #{user_id}")})
    end

    tmp = target_user.to_dictionary
    tmp[:session_key] = ''      # 清空session_key
    render_result(ResultCode::OK, tmp)
  end

  #
  # 更新用户信息
  #
  def update_user_info
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    name = get_params(params, :name)
    unless user.update_info(name, params)
      return render_result(ResultCode::ERROR, {err_msg: URI.encode(user.errors.full_messages.join('; '))})
    end

    render_result(ResultCode::OK, user.to_dictionary)
  end

  #
  # 修改用户门派
  #
  def update_zhangmen_name
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    name = get_params(params, :zhangmen_name)
    zhangmen_name = name.to_half_width.tr(@@n_symbol,'').gsub(/(\s|\\r|\\n)/,'')
    if zhangmen_name.nil? || zhangmen_name.length <= 0
      return render_result(ResultCode::INVALID_PARAMETERS, {err_msg: "invalid parameters"})
    end
    #s_words = HarmoniousDictionary.harmonious_words zhangmen_name

    #if !s_words.nil? and s_words.length > 0
    #  return render_result(ResultCode::INVALID_PARAMETERS,{:s_words => s_words})
    #end

    flag = user.update_zhangmen_name(zhangmen_name)
    if flag
      render_result(ResultCode::OK, {:zhangmen_name => zhangmen_name})
    else
      render_result(ResultCode::ERROR,{:err_msg => 'name exist'})
    end
  end

  #
  #更新用户元宝数
  #
  def update_gold
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    gold = get_params(params, :gold)
    if gold.nil? || gold.to_i < 0
      return render_result(ResultCode::INVALID_PARAMETERS, {err_msg: "invalid parameters"})
    end
    user.update_gold(gold)
    render_result(ResultCode::OK,{})
  end

  #
  # 更新物品
  #
  def update_goods
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    if goods.nil? || !goods.kind_of?(Array)
      return render_result(ResultCode::INVALID_PARAMETERS, {err_msg: "invalid parameters"})
    end

    unless UserGoods.update_goods(user, goods)
      return render_result(ResultCode::ERROR, {err_msg: "error..."})
    end
    render_result(ResultCode::OK, {})
  end

  #
  # 获取随机未使用的掌门名称
  #
  def get_random_zhangmen_name
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    location_array = ZhangmenrenConfig.instance.zhangmen_name_config['location']
    name_array = ZhangmenrenConfig.instance.zhangmen_name_config['name']
    location = "#{location_array[rand(location_array.size)]}"
    name = "#{name_array[rand(name_array.size)]}"
    while User.exists?(name: name)
      logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) random create zhangmen name: #{name}")
      name = "#{name_array[rand(name_array.size)]}"
    end

    zhangmen_name_hash = {}
    zhangmen_name_hash[:location] = URI.encode(location)
    zhangmen_name_hash[:name] = URI.encode(name)

    render_result(ResultCode::OK, zhangmen_name_hash)
  end

  #
  # 设置新手指引步骤数
  #
  def set_direction_step
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    direction_step = params[:direction_step]
    if direction_step.nil? || direction_step.to_i < 0
      render_result(ResultCode::INVALID_PARAMETERS, {err_msg: 'invalid parameters'})
      return
    end

    user.direction_step = direction_step
    user.save
    render_result(ResultCode::OK, {})
  end

  #
  # 获取用户战斗信息(传书)
  # 包括 论剑被挑战和被夺残章
  #
  def get_fight_messages
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    render_result(ResultCode::OK, User.get_fight_messages(user))
  end

  #
  # 获取用户全部信息(传书)
  #
  def get_all_messages
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    render_result(ResultCode::OK, User.get_all_messages(user))
  end

  #
  # 搜索用户
  #
  def search
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    search_word = get_params(params, :search_word)
    if(search_word.nil? || search_word.length < 0)
      return render_result(ResultCode::ERROR, {})
    end

    users = []
    #如果该搜索字符串匹配数值的正则表达式，则根据等级进行搜索，根据最近登陆时间降序排列
    if (/^[0-9]*[1-9][0-9]*$/ =~ search_word)
      users = User.get_user_list_by_level(search_word.to_i) #根据等级搜索
                                                            #如果该搜索字符串不匹配数值的正则表达式，则根据姓名进行搜索，根据最近登陆时间降序排列
    else
      users = User.get_user_list_by_name(search_word.to_s) #根据门派搜索
    end

    users_array = []
    users.each() do |user|
      user_hash = {}
      user_hash[:user_id] = user.id
      user_hash[:level] = user.level
      user_hash[:name] = URI.encode(user.name || '')
      users_array << user_hash
    end

    render_result(ResultCode::OK, users_array)
  end

  #
  # 更新用户冲级奖励
  #
  def update_upgrade_reward
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    upgrade_3_reward = params[:upgrade_3_reward]
    if upgrade_3_reward.nil? || upgrade_3_reward.to_i < 0
      return render_result(ResultCode::INVALID_PARAMETERS, {err_msg: 'invalid parameters'})
    end

    upgrade_5_reward = params[:upgrade_5_reward]
    if upgrade_5_reward.nil? || upgrade_5_reward.to_i < 0
      return  render_result(ResultCode::INVALID_PARAMETERS, {err_msg: 'invalid parameters'})
    end

    upgrade_10_reward = params[:upgrade_10_reward]
    if upgrade_10_reward.nil? || upgrade_10_reward.to_i < 0
      return render_result(ResultCode::INVALID_PARAMETERS, {err_msg: 'invalid parameters'})
    end

    upgrade_15_reward = params[:upgrade_15_reward]
    if upgrade_15_reward.nil? || upgrade_15_reward.to_i < 0
      return render_result(ResultCode::INVALID_PARAMETERS, {err_msg: 'invalid parameters'})
    end

    user.upgrade_3_reward = upgrade_3_reward.to_i
    user.upgrade_5_reward = upgrade_5_reward.to_i
    user.upgrade_10_reward = upgrade_10_reward.to_i
    user.upgrade_15_reward = upgrade_15_reward.to_i
    if user.save
      render_result(ResultCode::OK, {})
    else
      render_result(ResultCode::SAVE_FAILED, {err_msg: 'save failed.'})
    end
  end

  #花费元宝增加体力
  def add_power_by_gold
    re,user = validate_session_key(get_params(params, :session_key))
    return unless re
    gold = get_params(params,:gold)
    power = get_params(params,:power)

    most_exchange_time = ZhangmenrenConfig.instance.vip_config[user.vip_level.to_s]["power_recovery_time_per_day"]



    if(gold.nil?||power.nil?)
      return render_result(ResultCode::INVALID_PARAMETERS, {err_msg: 'invalid parameters'})
    end


    if(user.exchange_power_time < most_exchange_time)
      if(user.update_gold_power(gold,power))
        return render_result(ResultCode::OK,{})
      else
        return render_result(ResultCode::SAVE_FAILED,{err_msg:'save failed'})
      end
    end

    return render_result(ResultCode::ERROR,{error_msg: 'reached max times'})
  end

  #花费元宝增加气力
  def add_sprite_by_gold
    re,user = validate_session_key(get_params(params, :session_key))
    return unless re
    gold = get_params(params,:gold)
    sprite = get_params(params,:sprite)

    most_exchange_time = ZhangmenrenConfig.instance.vip_config[user.vip_level.to_s]["sprite_recovery_time_per_day"]

    if(gold.nil?||sprite.nil?)
      return render_result(ResultCode::INVALID_PARAMETERS, {err_msg: 'invalid parameters'})
    end

    if(user.exchange_sprite_time < most_exchange_time)
      if(user.update_gold_sprite(gold,sprite))
        return render_result(ResultCode::OK,{})
      else
        return render_result(ResultCode::SAVE_FAILED,{err_msg:'save failed'})
      end
    end

    return render_result(ResultCode::ERROR,{error_msg: 'reached max times'})
  end

  #获取用元宝购买体力的次数
  def get_exchange_power_time
    re,user = validate_session_key(get_params(params, :session_key))
    return unless re

    return render_result(ResultCode::OK,{exchange_power_time:user.exchange_power_time})
  end

  #获取用元宝购买气力的次数
  def get_exchange_sprite_time
    re,user = validate_session_key(get_params(params, :session_key))
    return unless re

    return render_result(ResultCode::OK,{exchange_sprite_time:user.exchange_sprite_time})
  end

  #获取用户体力
  def get_power
    re,user = validate_session_key(get_params(params, :session_key))
    return unless re

    render_result(ResultCode::OK,{power:user.power})
  end

  #获取用户气力
  def get_sprite
    re,user = validate_session_key(get_params(params, :session_key))
    return unless re

    render_result(ResultCode::OK,{sprite:user.sprite})
  end

  #获取用户回复体力和气力的信息
  def get_power_and_sprite_time
    re,user = validate_session_key(get_params(params, :session_key))
    return unless re

    time_power_next='00:00:00'
    time_power_all='00:00:00'
    time_sprite_next = '00:00:00'
    time_sprite_all = '00:00:00'

    if(user.power_time != nil)
      time = 1800-(Time.now - user.power_time).to_i%1800
      h=time/3600
      m=(time%3600)/60
      s=(time%3600)%60
      time_power_next='%02d'%h << ':' << '%02d'%m << ':' << '%02d'%s

      time =  (30-user.power-1)*1800 + 1800-(Time.now - user.power_time).to_i%1800
      h=time/3600
      m=(time%3600)/60
      s=(time%3600)%60
      time_power_all='%02d'%h << ':' << '%02d'%m << ':' << '%02d'%s
    end

    if(user.sprite_time != nil)
      time = 1800-(Time.now - user.sprite_time).to_i%1800
      h=time/3600
      m=(time%3600)/60
      s=(time%3600)%60
      time_sprite_next='%02d'%h << ':' << '%02d'%m << ':' << '%02d'%s

      time =  (12-user.sprite-1)*1800 + 1800-(Time.now - user.sprite_time).to_i%1800
      h=time/3600
      m=(time%3600)/60
      s=(time%3600)%60
      time_sprite_all='%02d'%h << ':' << '%02d'%m << ':' << '%02d'%s
    end

    if(user.power>=30)
      time_power_next='00:00:00'
      time_power_all='00:00:00'
    end
    if(user.sprite>=12)
      time_sprite_next = '00:00:00'
      time_sprite_all = '00:00:00'
    end

    return render_result(ResultCode::OK,{time_power_next:time_power_next,time_sprite_next:time_sprite_next,time_power_all:time_power_all,time_sprite_all:time_sprite_all})
  end

  #
  #充值完成后获取用户的元宝、银币、装备、物品、累计充值金额
  #
  def get_info_after_recharge
    re,user = validate_session_key(get_params(params, :session_key))
    return unless re

    data = {}
    data[:gold] = user.gold
    data[:silver] = user.silver
    data[:goods] = user.user_goods
    data[:equipments] = user.equipments
    data[:total_golds] = user.orders.inject(0.0) {|sum, order| sum + order.omoney }

    return render_result(ResultCode::OK, data)
  end
end
