class UserController < ApplicationController
  #
  # 注册接口
  #
  def register
    username = get_params(params, :username)
    password = get_params(params, :password)

    code, user = User.register(username, password, request)
    if code == ResultCode::OK
      render_result(code, user.to_dictionary)
      return
    end
    render_result(code, {err_msg: URI.encode(user.to_s)})
  end

  #
  # 登录接口
  #
  #def login
  #  username = get_params(params, :username)
  #  password = get_params(params, :password)

  #  code, user, continuous_login_reward = User.login(username, password, request)
  #  if code == ResultCode::OK
  #    return_hash = {}
  #    return_hash[:continuous_login_reward] = continuous_login_reward.to_dictionary
  #    return_hash[:user] = user.to_dictionary
  #    render_result(code, return_hash)
  #    return
  #  end
  #  render_result(code, {err_msg: URI.encode(user.to_s)})
  #end
  def login
    login_type = get_params(params,:login_type)  #true =>login from 91, false => login from appServer

    if login_type.to_i == 1
      uin = get_params(params, :uin)
      sessionId= get_params(params,:sessionId)

      code ,user = User.login_from_91server(uin,sessionId,request)
      continuous_login_reward = nil
    else
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
      render_result(code, return_hash)
      return
    end

    render_result(code, {err_msg: URI.encode(user.to_s)})

    return

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
      render_result(ResultCode::NO_SUCH_USER, {err_msg: URI.encode("no such user #{user_id}")})
      return
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
      render_result(ResultCode::ERROR, {err_msg: URI.encode(user.errors.full_messages.join('; '))})
      return
    end

    render_result(ResultCode::OK, user.to_dictionary)
  end

  #
  # 修改用户门派
  #
  def update_zhangmen_name
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    zhangmen_name = get_params(params, :zhangmen_name)
    if zhangmen_name.nil? || zhangmen_name.length <= 0
      render_result(ResultCode::INVALID_PARAMETERS, {err_msg: "invalid parameters"})
      return
    end
    user.update_zhangmen_name(zhangmen_name)
    render_result(ResultCode::OK, {})
  end

  #
  #更新用户元宝数
  #
  def update_gold
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    gold = get_params(params, :gold)
    if gold.nil? || gold.to_i < 0
      render_result(ResultCode::INVALID_PARAMETERS, {err_msg: "invalid parameters"})
      return
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

    goods = params[:goods]
    if goods.nil? || !goods.kind_of?(Array)
      render_result(ResultCode::INVALID_PARAMETERS, {err_msg: "invalid parameters"})
      return
    end

    unless UserGoods.update_goods(user, goods)
      render_result(ResultCode::ERROR, {err_msg: "error..."})
      return
    end
    render_result(ResultCode::OK, {})
  end

  #
  # 检查资源更新
  #
  def check_resources_update

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
      render_result(ResultCode::ERROR, {})
      return
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
      render_result(ResultCode::INVALID_PARAMETERS, {err_msg: 'invalid parameters'})
      return
    end

    upgrade_5_reward = params[:upgrade_5_reward]
    if upgrade_5_reward.nil? || upgrade_5_reward.to_i < 0
      render_result(ResultCode::INVALID_PARAMETERS, {err_msg: 'invalid parameters'})
      return
    end

    upgrade_10_reward = params[:upgrade_10_reward]
    if upgrade_10_reward.nil? || upgrade_10_reward.to_i < 0
      render_result(ResultCode::INVALID_PARAMETERS, {err_msg: 'invalid parameters'})
      return
    end

    upgrade_15_reward = params[:upgrade_15_reward]
    if upgrade_15_reward.nil? || upgrade_15_reward.to_i < 0
      render_result(ResultCode::INVALID_PARAMETERS, {err_msg: 'invalid parameters'})
      return
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

end
