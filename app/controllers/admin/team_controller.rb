#encoding: utf-8
class Admin::TeamController < ApplicationController
  layout 'admin'
  before_filter :validate_login_admin
  
  def index
    @user = User.find(session[:user_id])
    #用户的弟子。
    @disciples = @user.disciples
    if (@user.team_members.nil? || @user.team_members.length <= 0) &&
        (!@disciples.nil? && @disciples.length > 0)
      team_member = TeamMember.new(:user_id => @user.id, :disciple_id => @disciples.first.id, :position => -1)
      team_member.save
    end
    #上阵弟子。
    @on_battle_members = @user.team_members.where("position != ?", -1)
    @team_members = TeamMember.find_by_user_id(session[:user_id])

    #弟子、名称的解析。
    @d_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config
  end

  def update
    @user = User.find(session[:user_id])
    @disciples = @user.disciples
    @team_members = @user.team_members

    #弟子、名称的解析。
    @d_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config
    user_id = session[:user_id]

    #阵容的位置列表。
    @team_position = [-1,0,1,2,3,4,5,6,7]
    positions = params[:team_member][:tm_position]

    #获取位置不为-1的位置数组。
    position_list = []
    positions.each() do |p|
      next if p.to_i == -1
      position_list << p
    end

    #判断是否存在重复的位置。
    unless position_list.size == position_list.uniq.size
      flash[:error] = "上阵弟子位置不能重复"
      respond_to do |format|
        format.html { render :action => "edit" }
      end
      return
    end

    #用户的弟子id列表。
    disciple_ids = []
    @disciples.each() {|d|disciple_ids << d.id}
    n = positions.length - 1

    for i in 0..n do
      tm = TeamMember.find_by_disciple_id_and_user_id(disciple_ids[i].to_i, user_id)
      if tm.nil?
        next if positions[i] == -1
        tm = TeamMember.new
        tm.user_id = user_id
        tm.disciple_id = disciple_ids[i]
        tm.position = positions[i]
        return unless tm.save
      end
      re = tm.update_attributes(position: positions[i])

    end
    respond_to do |format|
      if re
        format.html{ redirect_to :action => :index}
      else
        format.html{ redirect_to :action => :edit}
      end
    end
  end

  def edit
    #弟子、名称的解析。
    @d_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config
    #阵容的位置列表。
    @team_position = [-1,0,1,2,3,4,5,6,7]
    @user = User.find(session[:user_id])
    @disciples = @user.disciples
    @team_members = @user.team_members
    if @team_members.nil? || @team_members.length <= 0
      team_member = TeamMember.new(:user_id => @user.id, :disciple_id => @disciples.first.id, :position => -1)
      team_member.save
    end
  end

  def show
  end

  #
  # 更换装备
  #
  def change_equipment
    @user = User.find_by_id(session[:user_id])
    @disciple_id = params[:id]
    user_equipment = @user.equipments
    disciple = Disciple.find_by_id(params[:id])

    #当前弟子的3件装备。
    first_disciple_equipment = disciple.equipments.find_by_position(0)
    second_disciple_equipment = disciple.equipments.find_by_position(1)
    third_disciple_equipment = disciple.equipments.find_by_position(2)

    #根据当前3件装备的类型找到当前弟子3件装备的名称
    unless first_disciple_equipment.nil?
      @first_disciple_equipment_name = first_disciple_equipment.
                                      change_type_to_name(first_disciple_equipment.e_type)
    end
    unless second_disciple_equipment.nil?
      @second_disciple_equipment_name = second_disciple_equipment.
                                      change_type_to_name(second_disciple_equipment.e_type)
    end
    unless third_disciple_equipment.nil?
      @third_disciple_equipment_name = third_disciple_equipment.
                                      change_type_to_name(third_disciple_equipment.e_type)
    end

    @names_config = ZhangmenrenConfig.instance.name_config
    @equipment_config = ZhangmenrenConfig.instance.equipment_config

    #初始化3件装备的装备名称，装备等级，装备id
    @first_e_names = [["无装备",0,0]]
    @second_e_names = [["无装备",0,0]]
    @third_e_names = [["无装备",0,0]]
    user_equipment.each() do |e|
      if @equipment_config[e.e_type]["type"] == 1
        @first_e_names << [@names_config[@equipment_config[e.e_type]["name"]],e.id, e.level]
      end
      if @equipment_config[e.e_type]["type"] == 2
        @second_e_names << [@names_config[@equipment_config[e.e_type]["name"]],e.id.to_i, e.level.to_i]
      end
      if @equipment_config[e.e_type]["type"] == 3
        @third_e_names << [@names_config[@equipment_config[e.e_type]["name"]],e.id, e.level]
      end
    end

    #更换装备的id
    first_id = params[:fir_equip]
    second_id = params[:sec_equip]
    third_id = params[:thi_equip]
    unless first_id.nil? && second_id.nil? && third_id.nil?
      #解除位置为0的装备
      if first_id.to_i == 0
        unless first_disciple_equipment.nil?
          first_disciple_equipment.update_attributes(disciple_id: -1, position: -1)
          first_disciple_equipment.save
        end
      end
      #解除位置为1的装备
      if second_id.to_i == 0
        unless second_disciple_equipment.nil?
          second_disciple_equipment.update_attributes(disciple_id: -1, position: -1)
          second_disciple_equipment.save
        end
      end
      #解除位置为2的装备
      if third_id.to_i == 0
        unless third_disciple_equipment.nil?
          third_disciple_equipment.update_attributes(disciple_id: -1, position: -1)
          third_disciple_equipment.save
        end
      end

      #其中有一个位置存在更换的装备。
      if first_id.to_i != 0 || second_id.to_i != 0 || third_id.to_i != 0
        @first_equipment = Equipment.find_by_id(first_id)
        @second_equipment = Equipment.find_by_id(second_id)
        @third_equipment = Equipment.find_by_id(third_id)
        if Equipment.exists?(:user_id => session[:user_id],:disciple_id => params[:id])
          equipments = disciple.equipments
          unless equipments.nil?
            equipments.each() do |e|
              e.change_position(e.id, first_id, second_id, third_id, session[:user_id])
            end
          end
        end
        unless @first_equipment.nil?
          @first_equipment.update_attributes(position: 0, disciple_id: params[:id])
          @first_equipment.save
        end
        unless @second_equipment.nil?
          @second_equipment.update_attributes(position: 1, disciple_id: params[:id])
          @second_equipment.save
        end
        unless @third_equipment.nil?
          @third_equipment.update_attributes(position: 2, disciple_id: params[:id])
          @third_equipment.save
        end
        respond_to do |format|
            format.html{redirect_to(action: :index)}
        end
      else
        respond_to do |format|
          format.html{redirect_to(action: :index)}
        end
      end
    end
  end

  #
  # 更换功夫
  #
  def change_gongfu
    @user = User.find_by_id(session[:user_id])
    @disciple_id = params[:id]
    user_gongfus = @user.gongfus

    #名称、功夫的解析。
    @names_config = ZhangmenrenConfig.instance.name_config
    @gf_config = ZhangmenrenConfig.instance.gongfu_config
    disciple = Disciple.find_by_id(@disciple_id)

    #当前弟子的2个武功。
    second_disciple_gongfu = disciple.gongfus.find_by_position(1)
    third_disciple_gongfu = disciple.gongfus.find_by_position(2)

    #找到当前弟子2个武功的名称
    unless second_disciple_gongfu.nil?
      @second_disciple_gongfu_name = second_disciple_gongfu.
                      change_type_to_name(second_disciple_gongfu.gf_type)
    end
    unless third_disciple_gongfu.nil?
      @third_disciple_gongfu_name = third_disciple_gongfu.
                      change_type_to_name(third_disciple_gongfu.gf_type)
    end

    #初始化功夫的名称，id，等级
    @gongfu_names = [["不添加武功", 0, 0]]
    unless user_gongfus.nil?
      user_gongfus.each() do |gf|
        @gongfu_names << [@names_config[@gf_config[gf.gf_type]["name"]], gf.id, gf.level, gf.experience]
      end
    end

    #所选功夫的id
    second_gf_id = params[:sec_gf]
    third_gf_id = params[:thi_gf]
    unless third_gf_id.nil?&&second_gf_id.nil?
      disciple = Disciple.find_by_id(params[:id])
      @second_gf = Gongfu.find_by_id(second_gf_id)
      @third_gf = Gongfu.find_by_id(third_gf_id)

      #判断第二个位置上是否无装备更换。
      if second_gf_id.to_i == 0
        unless second_disciple_gongfu.nil?
          second_disciple_gongfu.update_attributes(disciple_id: -1, position: -1)
          second_disciple_gongfu.save
        end
      end
      #判断第三个位置上是否无装备更换。
      if third_gf_id.to_i == 0
        unless third_disciple_gongfu.nil?
          third_disciple_gongfu.update_attributes(disciple_id: -1, position: -1)
          third_disciple_gongfu.save
        end
      end
      if second_gf_id.to_i != 0 || third_gf_id.to_i != 0

        #弟子的天赋武功。
        tianfu_gongfu = disciple.gongfus.find_by_position(0)

        @second_gongfu = Gongfu.find_by_id(second_gf_id)
        @third_gongfu = Gongfu.find_by_id(third_gf_id)
        if Gongfu.exists?(:user_id => session[:user_id],:disciple_id => params[:id])
          gongfus = disciple.gongfus
          unless gongfus.nil?
            gongfus.each() do |gf|
              next if gf.position == 0
              gf.change_position(gf.id, second_gf_id, third_gf_id, session[:user_id])
            end
          end
        end

        #判断所选功夫数否重复，名称相同
        if @second_gongfu.gf_type == @third_gongfu.gf_type
          flash[:error] = "功夫不能重复"
          respond_to do |format|
            format.html{render :action => 'change_gongfu'}
          end
        elsif tianfu_gongfu.gf_type == @second_gongfu.gf_type || tianfu_gongfu.gf_type == @third_gongfu.gf_type
          flash[:error] = "所更换功夫中包含天赋功夫。"
          respond_to do |format|
            format.html{render :action => 'change_gongfu'}
          end
        else
          unless @second_gongfu.nil?
            @second_gongfu.update_attributes(position: 1, disciple_id: params[:id])
            @second_gongfu.save
          end
          unless @third_gongfu.nil?
            @third_gongfu.update_attributes(position: 2, disciple_id: params[:id])
            @third_gongfu.save
          end
          respond_to do |format|
            format.html{redirect_to(action: :index)}
          end
        end
      else
        respond_to do |format|
          format.html{redirect_to(action: :index)}
        end
      end
    end
  end
end
