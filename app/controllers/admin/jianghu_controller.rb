#encoding: utf-8
class Admin::JianghuController < ApplicationController
  layout 'admin'
  before_filter :validate_login_admin

  def index
    user = User.find(session[:user_id])
    #解析江湖、条目、弟子、名称。
    #@jh_config = ZhangmenrenConfig.instance.jianghu_config
    #@item_config = ZhangmenrenConfig.instance.item_config
    #@disciple_config = ZhangmenrenConfig.instance.disciple_config
    #@names_config = ZhangmenrenConfig.instance.name_config

    #用户江湖记录。
    @jianghu = user.jianghu_recorders.paginate(:page => params[:page])

    @jianghus_info = {}
    @jianghu.each() do |jh|
      @jianghus_info[jh.id] = jh.get_jianghu_details
    end
  end

  def edit
    @jianghu = JianghuRecorder.find(params[:id])
    @is_finish = %w(未完成 已完成)

    #解析江湖、弟子、名称。
    @jh_config = ZhangmenrenConfig.instance.jianghu_config
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config
  end

  def update
    @jianghu = JianghuRecorder.find(params[:id])

    #江湖记录的完成情况。
    @is_finish = %w(未完成 已完成)

    #解析江湖、弟子、名称。
    @jh_config = ZhangmenrenConfig.instance.jianghu_config
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config

    finish = params[:jianghu][:is_finish]
    fight_time = params[:jianghu][:fight_time]
    star = params[:jianghu][:star]
    if finish == "未完成"
      is_finish = false
    else
      is_finish = true
    end
    re = @jianghu.update_attributes(is_finish: is_finish, fight_time: fight_time, star: star)
    respond_to do |format|
      if re
        format.html {redirect_to(action: :show, id: @jianghu.id)}
      else
        format.html {render(action: :edit)}
      end
    end
  end

  def show
    @jianghu_id = params[:id]
    @jianghu = JianghuRecorder.find(params[:id])

    #解析江湖、弟子、名称。
    #@jh_config = ZhangmenrenConfig.instance.jianghu_config
    #@disciple_config = ZhangmenrenConfig.instance.disciple_config
    #@names_config = ZhangmenrenConfig.instance.name_config

    @jianghu_info = {}
    @jianghu_info[params[:id]] = @jianghu.get_jianghu_details
    logger.debug{"@jianghu_info = #{@jianghu_info}"}
  end

  #
  # 得到江湖的场景名称
  #
  def scene_names
    #解析江湖、名称。
    @jh_config = ZhangmenrenConfig.instance.jianghu_config
    @names_config = ZhangmenrenConfig.instance.name_config
    @scene_names = []
    @jh_config.keys.each() do |jh|
      @scene_names << @names_config[@jh_config[jh]["name"]]
    end
    data = @scene_names
    render_result(ResultCode::OK, data)
  end

  #
  # 得到江湖的条目名称
  #
  def item_names
    #解析江湖、名称。
    @jh_config = ZhangmenrenConfig.instance.jianghu_config
    @names_config = ZhangmenrenConfig.instance.name_config
    @item_names = []
    @jh_config.keys.each() do |jh|
      @jh_config[jh]["items"].each() do |item|
        next if item["name"].nil?
        @item_names << [jh - 1, @names_config[item["name"]]]
      end
    end

    data = @item_names
    render_result(ResultCode::OK, data)
  end

  #
  # 得到江湖的条目名称以及对应的场景名称
  #
  def scene_item_names

    #解析江湖、弟子、名称。
    @jh_config = ZhangmenrenConfig.instance.jianghu_config
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config
    user = User.find(session[:user_id])
    jianghus = user.jianghu_recorders
    item_names = []
    jianghus.each() do |jh|
      item_names << @names_config[@jh_config[jh.scene_id]["items"][jh.item_id - 1]["name"]]
    end
    @scene_item_names = []
    @jh_config.keys.each() do |jh|
      @jh_config[jh]["items"].each() do |item|
        next if item["name"].nil? || item_names.include?(@names_config[item["name"]])
        @scene_item_names << [@names_config[@jh_config[jh]["name"]], @names_config[item["name"]]]
      end
    end
    data = @scene_item_names
    render_result(ResultCode::OK, data)
  end

  def new
    @jianghu = JianghuRecorder.new
    @is_finish = %w(未完成 已完成)

    #解析江湖、弟子、名称。
    @jh_config = ZhangmenrenConfig.instance.jianghu_config
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config
  end

  def create
    @is_finish = %w(未完成 已完成)

    #解析江湖、弟子、名称。
    @jh_config = ZhangmenrenConfig.instance.jianghu_config
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config
    finish = params[:jianghu][:is_finish]
    scene = params[:scene_name]
    item = params[:item_name]
    fight_time = params[:jianghu][:fight_time]
    star = params[:jianghu][:star]
    scene_name = ''
    item_name = ''
    scene_id = 0
    item_id = 0

    #获得江湖的场景，条目对应的keys
    @names_config.keys.each() do |n|
      if @names_config[n] == scene
        scene_name = n
      elsif @names_config[n] == item
        item_name = n
      end
    end

    #获得场景和条目对应的id
    @jh_config.keys.each() do |jh|
      if @jh_config[jh]["name"] == scene_name
        scene_id = jh
        @jh_config[jh]["items"].each() do |item|
          if item["name"] == item_name
            item_id = item["id"]
          end
        end
      end
    end
    if finish == "未完成"
      is_finish = false
    else
      is_finish = true
    end
    @jianghu = JianghuRecorder.new(is_finish: is_finish, fight_time: fight_time, star: star, item_id: item_id,
                                  scene_id: scene_id, user_id: session[:user_id])

    if item == "该场景已完成"
      flash[:error] = "该场景已完成，请选择其他场景！"
      respond_to do |format|
        format.html{render :action => 'new' }
      end
    else
      respond_to do |format|
        if @jianghu.save
          format.html {redirect_to(action: :show, id: @jianghu.id)}
        else
          format.html {render(action: :new)}
        end
      end
    end
  end

  def delete
    jianghu = JianghuRecorder.find(params[:id])
    jianghu.destroy unless jianghu.nil?
    redirect_to(action: :index)
  end
end
