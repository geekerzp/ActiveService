#encoding: utf-8

require 'will_paginate/array'
class Admin::EquipmentController < ApplicationController
  layout 'admin'
  before_filter :validate_login_admin

  def new
    @equipment = Equipment.new
    #残章，功夫，名称的解析文件。
    @equipment_config = ZhangmenrenConfig.instance.equipment_config
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config
    @equipment_types_list = %w(攻击 防御 坐骑)
  end

  def create
    e_type = params[:e_name]
    level = params[:equipment][:level]
    grow_strength = params[:equipment][:grow_strength]
    #弟子，装备，名称的解析文件。
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @equipment_config = ZhangmenrenConfig.instance.equipment_config
    @names_config = ZhangmenrenConfig.instance.name_config

    #装备类型列表
    @equipment_types_list = %w(攻击 防御 坐骑)

    #装备的名称，类型
    e_name = ''
    equipment_type = ''
    @names_config.keys.each() do |n|
      if @names_config[n] == e_type
        e_name = n
      end
    end
    @equipment_config.keys.each() do |e|
      if @equipment_config[e]["name"] == e_name
        equipment_type = e
      end
    end
    @equipment = Equipment.new(user_id: session[:user_id], e_type: equipment_type, disciple_id: -1,
                               level: level, grow_strength: grow_strength)
    respond_to do |format|
      if @equipment.save
        format.html { redirect_to(:action => :show, :id => @equipment.id) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def index
    @user = User.find(session[:user_id])
    @equipments = @user.equipments.paginate(:page => params[:page])
    #弟子，装备，名称的解析文件。
    #@equipment_config = ZhangmenrenConfig.instance.equipment_config
    #@names_config = ZhangmenrenConfig.instance.name_config
    #@disciple_config = ZhangmenrenConfig.instance.disciple_config

    #用户的装备信息存在字典数据中
    @equipments_info = {}
    @equipments.each() do |e|
      @equipments_info[e.id] = e.get_equipment_detail
    end
  end

  def delete
    equipment = Equipment.find_by_id(params[:id])
    equipment.destroy unless equipment.nil?
    redirect_to(action: :index)
  end

  def show
    @equipment = Equipment.find(params[:id])
    #装备，名称的解析文件。
    @equipment_config = ZhangmenrenConfig.instance.equipment_config
    @names_config = ZhangmenrenConfig.instance.name_config

    #查看的装备信息存在字典数据中
    @equipment_info = {}
    @equipment_info[params[:id]] = @equipment.get_equipment_detail
  end

  def edit
    user = User.find(session[:user_id])
    @equipment = Equipment.find(params[:id])

    #编辑的装备信息存在字典数据中
    @equipment_info = {}
    @equipment_info[params[:id]] = @equipment.get_equipment_detail

    @disciples = user.disciples
    team_members = user.team_members.where("position != ?", -1)

    #弟子，装备，名称的解析文件。
    @equipment_config = ZhangmenrenConfig.instance.equipment_config
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config

    #上阵弟子id列表。
    team_members_disciple_ids = []
    team_members.each() do |t|
      team_members_disciple_ids << t.disciple_id
    end

    @disciple_list = {-1 => "不装备任何弟子"}
    @disciples.each() do |d|
      next unless team_members_disciple_ids.include?(d.id)
      equipments = d.equipments
      disciple_equipment_types = []
      equipments.each() do |e|
        disciple_equipment_types << @equipment_config[e.e_type]["type"]
      end
      next if Equipment.exists?(disciple_id: d.id,e_type: @equipment.e_type) ||
          disciple_equipment_types.include?(@equipment_config[@equipment.e_type]["type"])
      @disciple_list[d.id] = @names_config[@disciple_config[d.d_type]["name"]]
    end

    #若存在装备改装备的弟子，则要在弟子列表中加入该弟子。
    unless @equipment_info[params[:id]][:disciple_name] == "未使用"
      @disciple_list[@equipment_info[params[:id]][:disciple_id]] = @equipment_info[params[:id]][:disciple_name]
    end
  end

  def update
    @equipment = Equipment.find(params[:id])
    #弟子，装备，名称的解析文件。
    @equipment_config = ZhangmenrenConfig.instance.equipment_config
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config

    #编辑的装备信息存在字典数据中
    @equipment_info = {}
    @equipment_info[params[:id]] = @equipment.to_dictionary

    level = params[:equipment][:level]
    grow_strength = params[:equipment][:grow_strength]
    disciple = params[:equipment][:disciple]
    position = @equipment_config[@equipment.e_type]["type"] - 1
    user = User.find(session[:user_id])
    @disciples = user.disciples
    team_members = user.team_members.where("position != ?", -1)
    team_members_disciple_ids = []
    team_members.each() do |t|
      team_members_disciple_ids << t.disciple_id
    end
    @disciple_list = {-1 => "不装备任何弟子"}
    d_name = ''
    @names_config.keys.each() do |n|
      if @names_config[n] == disciple
        d_name = n
      end
    end
    new_disciple_id = @equipment.disciple_id
    @disciples.each() do |d|
      unless team_members_disciple_ids.include?(d.id)
        @disciple_list[-1] = "不装备任何弟子"
      end
      @disciple_list[d.id] = @names_config[@disciple_config[d.d_type]["name"]]
      if disciple == "不装备任何弟子"
        new_disciple_id = -1
        position = -1
      elsif @disciple_config[d.d_type]["name"] == d_name
        new_disciple_id = d.id
      end
    end

    if new_disciple_id.to_i != 0 && new_disciple_id == new_disciple_id.to_i.to_s
      d = Disciple.find_by_id(new_disciple_id)
      unless @disciples.include?(d)
        flash[:error] = "不是该用户弟子"
        respond_to do |format|
          format.html { render :action => "edit" }
        end
        return
      end
      if d.equipments.count == 3
        flash[:error] = "该弟子已经拥有3件装备，不能再添加"
        respond_to do |format|
          format.html { render :action => "edit" }
        end
        return
      end
    end

    unless @equipment.update_attributes(level: level, disciple_id: new_disciple_id,
                                        grow_strength: grow_strength, position: position)
      respond_to { |format| format.html{ render :action => :edit, :id => @equipment.id}}
      return
    end
    respond_to { |format| format.html{ redirect_to :action => :show, :id => @equipment.id}}
  end

  #
  # 得到装备的类型和名称
  #
  def get_equipment_type_name
    @equipment_config = ZhangmenrenConfig.instance.equipment_config
    @names_config = ZhangmenrenConfig.instance.name_config

    #装备的类型和名称列表。
    equipment_type_name_list = []
    @equipment_config.keys.each() do |e|
      equipment_type_name_list << [@names_config[@equipment_config[e]["name"]], @equipment_config[e]["type"]]
    end

    data = equipment_type_name_list
    render_result(ResultCode::OK, data)
  end
end
