#encoding: utf-8

require 'will_paginate/array'
class Admin::GongfuController < ApplicationController
  layout 'admin'
  before_filter :validate_login_admin

  def index
    user = User.find(session[:user_id])
    #当前用户的功夫
    @gongfus = user.gongfus.paginate(:page => params[:page])

    ##功夫，弟子，名称的解析。
    #@gf_config = ZhangmenrenConfig.instance.gongfu_config
    #@disciple_config = ZhangmenrenConfig.instance.disciple_config
    #@names_config = ZhangmenrenConfig.instance.name_config

    #用户功夫信息以字典形式存储
    @gongfus_info = {}
    @gongfus.each() do |gf|
      @gongfus_info[gf.id] = gf.get_gongfu_details
    end
    @gongfus_info.keys.each() do |gf|
    end
  end

  def new
    @gongfu = Gongfu.new
    #功夫，弟子，名称的解析。
    @gongfu_config = ZhangmenrenConfig.instance.gongfu_config
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config
  end

  def create
    level = params[:gongfu][:level]
    grow_strength = params[:gongfu][:grow_strength]
    gongfu = params[:gongfu][:gf_type]
    experience = params[:gongfu][:experience]

    #功夫的名称与类型
    gf_name = ''
    gf_type = ''
    #功夫，弟子，名称的解析。
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @gongfu_config = ZhangmenrenConfig.instance.gongfu_config
    @names_config = ZhangmenrenConfig.instance.name_config

    #找到功夫的名称
    @names_config.keys.each() do |n|
      if @names_config[n] == gongfu
        gf_name = n
      end
    end
    #找到功夫的类型
    @gongfu_config.keys.each() do |gf|
      if @gongfu_config[gf]["name"] == gf_name
        gf_type = gf
      end
    end
    @gongfu = Gongfu.new(user_id: session[:user_id], gf_type: gf_type, disciple_id: -1,
                         level: level, grow_strength: grow_strength, grow_probability: 0,
                         experience: experience)
    respond_to do |format|
      if @gongfu.save
        format.html { redirect_to(:action => :show, :id => @gongfu.id) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def edit
    user = User.find(session[:user_id])
    @gongfu = Gongfu.find(params[:id])
    @disciples = user.disciples

    #编辑的功夫信息存在字典数据中
    @gongfu_info = {}
    @gongfu_info[params[:id]] = @gongfu.get_gongfu_details

    #功夫，弟子，名称的解析。
    @gf_config = ZhangmenrenConfig.instance.gongfu_config
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config


    #找到上阵弟子的id
    team_members = user.team_members.where("position != ?", -1)
    team_members_disciple_ids = []
    team_members.each() do |t|
      team_members_disciple_ids << t.disciple_id
    end

    @disciple_list = {-1 => "不装备任何弟子"}
    #找到用户的上阵弟子，并排除已装备该功夫的弟子。
    @disciples.each() do |d|
      next unless team_members_disciple_ids.include?(d.id)
      next if Gongfu.where(disciple_id: d.id, gf_type: @gongfu.gf_type).exists?
      @disciple_list[d.id] = @names_config[@disciple_config[d.d_type]["name"]]
    end

    #若存在装备改功夫的弟子，则要在弟子列表中加入该弟子。
    unless @gongfu_info[params[:id]][:disciple_name] == "未使用"
      @disciple_list[@gongfu_info[params[:id]][:disciple_id]] = @gongfu_info[params[:id]][:disciple_name]
    end
  end

  def show
    @gongfu = Gongfu.find(params[:id])
    #功夫，弟子，名称的解析。
    @gf_config = ZhangmenrenConfig.instance.gongfu_config
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config
    disciple = Disciple.find_by_id(@gongfu.disciple_id)
    @disciple_name = ''
    if disciple.nil?
      @disciple_name = "未使用"
    else
      @disciple_name = @names_config[@disciple_config[disciple.d_type]["name"]]
    end
  end

  def update
    level = params[:gongfu][:level]
    disciple = params[:gongfu][:disciple]
    grow_strength = params[:gongfu][:grow_strength]
    experience = params[:gongfu][:experience]
    user = User.find(session[:user_id])
    @gongfu = Gongfu.find(params[:id])
    @disciples = user.disciples

    #编辑的功夫信息存在字典数据中
    @gongfu_info = {}
    @gongfu_info[params[:id]] = @gongfu.get_gongfu_details

    #功夫，弟子，名称的解析。
    @gf_config = ZhangmenrenConfig.instance.gongfu_config
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config
    team_members = user.team_members.where("position != ?", -1)
    #找到上阵弟子的id
    team_members_disciple_ids = []
    team_members.each() do |t|
      team_members_disciple_ids << t.disciple_id
    end
    @disciple_list = {-1 => "不装备任何弟子"}
    disciple_id = @gongfu.disciple_id
    d_name = ''
    @names_config.keys.each() do |n|
      if @names_config[n] == disciple
        d_name = n
      end
    end
    @disciples.each() do |d|
      next unless team_members_disciple_ids.include?(d.id)
      next if Gongfu.where(disciple_id: d.id, gf_type: @gongfu.gf_type).exists?
      @disciple_list[d.id] = @names_config[@disciple_config[d.d_type]["name"]]
      if disciple == "不装备任何弟子"
        disciple_id = -1
      elsif @disciple_config[d.d_type]["name"] == d_name
        disciple_id = d.id
      end
    end
    #若存在装备该功夫的弟子，则要在弟子列表中加入该弟子。
    unless @gongfu_info[params[:id]][:disciple_name] == "未使用"
      @disciple_list[@gongfu_info[params[:id]][:disciple_id]] = @gongfu_info[params[:id]][:disciple_name]
    end

    re = @gongfu.update_attributes(level: level, disciple_id: disciple_id, grow_strength: grow_strength,
                                   experience: experience)
    respond_to do |format|
      if re
        format.html{ redirect_to :action => :show, :id => @gongfu.id}
      else
        format.html{ render :action => :edit}
      end
    end
  end

  def delete
    gf = Gongfu.find_by_id(params[:id])
    gf.destroy unless gf.nil?
    redirect_to(action: :index)
  end
end
