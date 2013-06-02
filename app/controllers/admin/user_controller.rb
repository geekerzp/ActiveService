#encoding: utf-8
class Admin::UserController < ApplicationController
  layout 'admin'
  before_filter :validate_login_admin

  def index
    @users = User.where(status: User::USER_STATUS_NORMAL).order('created_at desc').paginate(:page => params[:page])
    session[:user_id] = nil
  end

  def search
    search_key = '%' + params[:search_key] + '%'
    @users = User.where(["username like ? or name like ?", search_key, search_key]).
                        order('created_at desc').paginate(:page => params[:page])
  end

  def show
    @user = User.find_by_id(params[:id])
    session[:user_id] = params[:id]

    #弟子、名称的解析。
    @names_config = ZhangmenrenConfig.instance.name_config
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
  end

  def edit
    @user = User.find_by_id(params[:id])

    #用户的vip等级。
    @vip_level_list = [0,1,2,3,4,5,6,7,8,9,10,11,12]
  end
  def update
    #用户的vip等级。
    @vip_level_list = [0,1,2,3,4,5,6,7,8,9,10,11,12]

    @user = User.find_by_id(params[:id])
    @user.level = params[:user][:level]
    @user.name = params[:user][:name]
    @user.username = params[:user][:username]
    @user.prestige = params[:user][:prestige]
    @user.gold = params[:user][:gold]
    @user.silver = params[:user][:silver]
    @user.power = params[:user][:power]
    @user.experience = params[:user][:experience]
    @user.sprite = params[:user][:sprite]
    @user.vip_level = params[:user][:vip_level]

    #不同等级对应的不同经验上限。
    @experiences_config = ZhangmenrenConfig.instance.user_experiences_config
    if params[:user][:level].to_i <= 100
      #判断该等级下经验是否超过上限。
      if @experiences_config[params[:user][:level].to_i] < params[:user][:experience].to_i
        flash[:error] = "等级为#{params[:user][:level]}的用户的经验不能超过
                        #{@experiences_config[params[:user][:level].to_i]}"
        respond_to do|format|
          format.html{render(action: :edit)}
        end
      else
        respond_to do |format|
          if @user.save
            format.html {redirect_to(action: :show, id: @user.id)}
          else
            logger.debug("--------------------------#{@user.vip_level}")
            logger.debug("--------------------------#{@user}")
            format.html {render(action: :edit)}
          end
        end
      end
    else
      respond_to do |format|
        if @user.save
          format.html {redirect_to(action: :show, id: @user.id)}
        else
          format.html {render(action: :edit)}
        end
      end
    end



  end

  def delete
    user = User.find(params[:id])
    user.destroy unless user.nil?
    redirect_to(action: :index)
  end

  #
  # 修改密码
  #
  def change_password
    new_password = params[:new_password]
    repeat_password = params[:repeat_password]
    @user = User.find(session[:user_id])

    if new_password.nil? && repeat_password.nil?
      respond_to do |format|
        format.html { render :layout => "admin" }
      end
      return
    end

    #新密码为空或者长度小于6.
    if new_password.nil? || new_password.length < 6
      flash[:error] = "新密码长度要大于等于6个字符"
      respond_to do |format|
        format.html { render :layout => "admin" }
      end
      return
    end

    #新密码与确认密码不一致。
    if new_password != repeat_password
      flash[:error] = "新密码两次输入不匹配"
      respond_to do |format|
        format.html { render :layout => "admin" }
      end
      return
    end

    @user.password = Digest::SHA2.hexdigest(new_password).to_s
    if @user.save
      flash[:success] = "密码修改成功！"
    else
      flash[:error] = "修改失败，请重试。"
    end
    respond_to do |format|
      format.html { render :layout => "admin" }
    end
  end

  def new
    @user = User.new
    @user.power = 30
    @user.sprite = 12
    @user.gold = 30
    @user.silver = 100

    #用户Vip等级
    @vip_level_list = [0,1,2,3,4,5,6,7,8,9,10,11,12]
  end

  def create
    level = params[:user][:level]
    name = params[:user][:name]
    username = params[:user][:username]
    prestige = params[:user][:prestige]
    gold = params[:user][:gold]
    silver = params[:user][:silver]
    power = params[:user][:power]
    experience = params[:user][:experience]
    sprite = params[:user][:sprite]
    password = params[:password]
    vip_level = params[:user][:vip_level]
    @vip_level_list = [0,1,2,3,4,5,6,7,8,9,10,11,12]

    @user = User.new
    @user.username = username
    @user.password = Digest::SHA2.hexdigest(password).to_s
    @user.name = name
    @user.prestige = prestige
    @user.gold = gold
    @user.silver = silver
    @user.power = power
    @user.experience = experience
    @user.sprite = sprite
    @user.level = level
    @user.vip_level = vip_level
    @experiences_config = ZhangmenrenConfig.instance.user_experiences_config

    if level.to_i <= 100
      #判断该等级下经验是否超过上限。
      if @experiences_config[level.to_i - 1] < experience.to_i
        flash[:error] = "等级为#{level}的用户的经验不能超过
                        #{@experiences_config[level.to_i - 1]}"
        respond_to do|format|
          format.html{render(action: :new)}
        end
      else
        respond_to do |format|
          if @user.save
            # 初始化背包中的数据
            init_user_goods(@user.id)
            # 创建4个类型的掌门诀。
            @zhangmenjue_type_1 = Zhangmenjue.new(user_id: @user.id, z_type: 1)
            @zhangmenjue_type_2 = Zhangmenjue.new(user_id: @user.id, z_type: 2)
            @zhangmenjue_type_3 = Zhangmenjue.new(user_id: @user.id, z_type: 3)
            @zhangmenjue_type_4 = Zhangmenjue.new(user_id: @user.id, z_type: 4)
            if@zhangmenjue_type_1.save && @zhangmenjue_type_2.save &&@zhangmenjue_type_3.save && @zhangmenjue_type_4.save
              format.html {redirect_to(action: :show, id: @user.id)}
            end
          else
            format.html {render(action: :new)}
          end
        end
      end
    else
      respond_to do |format|
        if @user.save
          # 初始化背包中的数据
          init_user_goods(@user.id)
          format.html {redirect_to(action: :show, id: @user.id)}
        else
          format.html {render(action: :new)}
        end
      end
    end

  end


  def init_user_goods(user_id)
=begin
    # 后台初始用户加入（	装备）手戟*1
    equipment_1 = Equipment.new
    equipment_1.e_type = 'equipment_weapon_1001'
    equipment_1.grow_strength = 0
    equipment_1.level = 1
    equipment_1.position = -1
    equipment_1.disciple_id = -1
    equipment_1.user_id = user_id
    equipment_1.save
=end

    # 后台初始用户加入（	装备）松纹古锭刀*1
    equipment_2 = Equipment.new
    equipment_2.e_type = 'equipment_weapon_2002'
    equipment_2.grow_strength = 0
    equipment_2.level = 1
    equipment_2.position = -1
    equipment_2.disciple_id = -1
    equipment_2.user_id = user_id
    equipment_2.save

    # 后台初始用户加入（	残章）武功残章 * 1飞煌斩 残章1
    canzhang_1 = Canzhang.new
    canzhang_1.cz_type = 'gongfu_2001_canzhang_1'
    canzhang_1.number = 1
    canzhang_1.user_id = user_id
    canzhang_1.save

=begin
    # 后台初始用户加入（道具）新手礼包 *1
    user_good_1 = UserGoods.new
    user_good_1.g_type = 'name_newplayergift_0001'
    user_good_1.number = 1
    user_good_1.user_id = user_id
    user_good_1.save
=end

  end
end
