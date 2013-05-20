#encoding: utf-8
require 'will_paginate/array'
class Admin::DiscipleController < ApplicationController
  layout 'admin'
  before_filter :validate_login_admin

  def show
    @disciple = Disciple.find_by_id(params[:id])

    #弟子，功夫，名称的解析文件。
    disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config
    @equipment_config = ZhangmenrenConfig.instance.equipment_config
    @gongfu_config = ZhangmenrenConfig.instance.gongfu_config

    #弟子的名称
    @name = @names_config[disciple_config[@disciple.d_type]["name"]]
  end

  def index
    user = User.find(session[:user_id])
    @disciples = user.disciples.paginate(:page => params[:page])
    #弟子，名称的解析文件。
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config

    @disciples_info_list = []
    is_team_member = ""
    @disciples.each() do |d|
      team_member = TeamMember.find_by_user_id_and_disciple_id(session[:user_id], d.id)
      if team_member.nil? || team_member.position == -1
        is_team_member = "未上阵"
      else
        is_team_member = "已上阵"
      end
      @disciples_info_list << [d, is_team_member]
    end
  end

  def edit
    @disciple = Disciple.find_by_id(params[:id])

    #弟子，名称的解析文件。
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config
  end

  def update
    @disciple = Disciple.find_by_id(params[:id])
    #弟子，名称，弟子不同等级的经验的解析文件。
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config
    @experiences_config = ZhangmenrenConfig.instance.disciple_experiences_config

    level = params[:disciple][:level]
    experience = params[:disciple][:experience]
    grow_blood = params[:disciple][:grow_blood]
    grow_attack = params[:disciple][:grow_attack]
    grow_defend = params[:disciple][:grow_defend]
    grow_internal = params[:disciple][:grow_internal]
    break_time = params[:disciple][:break_time]
    potential = params[:disciple][:potential]

    if level.to_i < 100
      if @experiences_config[level.to_i] < experience.to_i
        flash[:error] = "等级为#{level}的弟子的经验不能超过#{@experiences_config[level.to_i]}"
        respond_to do |format|
          format.html{ render :action => :edit}
        end
      else
        re = @disciple.update_attributes(level: level, experience: experience, grow_blood: grow_blood,
                                         grow_attack: grow_attack, grow_defend: grow_defend,
                                         grow_internal: grow_internal, break_time: break_time, potential:potential)

        respond_to do |format|
          if re
            format.html{ redirect_to :action => :show, :id => @disciple.id}
          else
            format.html{ render :action => :edit}
          end
        end
      end
    else
      re = @disciple.update_attributes(level: level, experience: experience, grow_blood: grow_blood,
                                       grow_attack: grow_attack, grow_defend: grow_defend,
                                       grow_internal: grow_internal, break_time: break_time, potential:potential)
      respond_to do |format|
        if re
          format.html{ redirect_to :action => :show, :id => @disciple.id}
        else
          format.html{ render :action => :edit}
        end
      end
    end
  end

  def delete
    disciple = Disciple.find_by_id(params[:id])

    team_member = TeamMember.find_by_disciple_id_and_user_id(params[:id],session[:user_id])
    team_member.destroy unless team_member.nil?
    equipments = disciple.equipments
    gongfus = disciple.gongfus

    #删除弟子时，将弟子的装备更新为无人装备，位置改为-1。
    equipments.each() do |e|
      e.update_attributes(disciple_id: -1, position: -1)
      e.save
    end

    #删除弟子时，将弟子的武功更新为无人装备，位置改为-1，并删除天赋功夫。
    gongfus.each() do |gf|
      if gf.position == 0
        gf.destroy
      else
        gf.update_attributes(disciple_id: -1, position: -1)
        gf.save
      end

    end
    disciple.destroy unless disciple.nil?
    redirect_to(action: :index)
  end

  def new
    @disciple = Disciple.new
    #弟子，名称，功夫的解析文件。
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config
    @gongfu_config = ZhangmenrenConfig.instance.gongfu_config

    #获得功夫名称列表
    @gongfu_names_list = []
    @gongfu_config.keys.each() do |gf|
      @gongfu_names_list << @names_config[@gongfu_config[gf]["name"]]
    end

    #当前用户拥有的弟子。
    @d_types = Disciple.where(["user_id = ?", session[:user_id]]).select(:d_type).uniq
    #当前用户拥有的弟子类型列表。
    dt = []
    @d_types.each() do |d|
      dt << d.d_type
    end


    @disciples = []
    @disciple_config.keys.each do |d|
      next if dt.include?(d)
      @disciples << @disciple_config[d]["name"]
    end
  end

  def create
    name = params[:disciple][:name]
    level = params[:disciple][:level]
    experience = params[:disciple][:experience]
    grow_blood = params[:disciple][:grow_blood]
    grow_attack = params[:disciple][:grow_attack]
    grow_defend = params[:disciple][:grow_defend]
    grow_internal = params[:disciple][:grow_internal]
    break_time = params[:disciple][:break_time]
    potential = params[:disciple][:potential]

    #弟子，名称，功夫的解析文件。
    @experiences_config = ZhangmenrenConfig.instance.disciple_experiences_config
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @gongfu_config = ZhangmenrenConfig.instance.gongfu_config
    @names_config = ZhangmenrenConfig.instance.name_config
    #当前用户拥有的弟子。
    @d_types = Disciple.where(["user_id = ?", session[:user_id]]).select(:d_type).uniq
    #天赋功夫的类型
    tianfu_gongfu_type = ''

    #弟子类型列表
    dt = []
    @d_types.each() do |d|
      dt << d.d_type
    end

    @disciples = []
    @disciple_config.keys.each do |d|
      next if dt.include?(d)
      @disciples << @disciple_config[d]["name"]
    end
    d_name = ''
    @names_config.keys.each() do |n|
      if @names_config[n] == name
        d_name = n
      end
    end
    d_type = ""
    @disciple_config.keys.each() do |d|
      if @disciple_config[d]["name"] == d_name
        d_type = d
        tianfu_gongfu_type = @disciple_config[d]["origin_gongfu"]
      end
    end
    @disciple = Disciple.new(user_id: session[:user_id], d_type: d_type, level: level, experience: experience,
                             grow_blood: grow_blood,grow_attack: grow_attack, grow_defend: grow_defend,
                             grow_internal: grow_internal, break_time: break_time, potential: potential)

    if level.to_i < 100
      if @experiences_config[level.to_i] < experience.to_i
        flash[:error] = "等级为#{level}的弟子的经验不能超过#{@experiences_config[level.to_i]}"
        respond_to do |format|
          format.html{ render :action => :new}
        end
      else
        respond_to do |format|
          if @disciple.save
            #创建天赋武功
            @tianfu_gongfu = Gongfu.new(disciple_id: @disciple.id, user_id:session[:user_id], position: 0,
                                        gf_type:tianfu_gongfu_type)
            if @tianfu_gongfu.save
              format.html { redirect_to(:action => :show, :id => @disciple.id) }
            end
          else
            format.html { render :action => "new" }
          end
        end
      end
    else
      respond_to do |format|
        if @disciple.save
          format.html { redirect_to(:action => :show, :id => @disciple.id) }
        else
          format.html { render :action => "new" }
        end
      end
    end
  end
end
