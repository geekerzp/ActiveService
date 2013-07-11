#ecoding: utf-8
class Admin::CanzhangController < ApplicationController
  layout 'admin'
  before_filter :validate_login_admin

  def index
    user = User.find(session[:user_id])
    #用户的残章列表;残章，功夫，名称的解析文件。
    @cangzhangs = user.canzhangs.paginate(:page => params[:page])
    @cz_config = ZhangmenrenConfig.instance.canzhang_config
    @gf_config = ZhangmenrenConfig.instance.gongfu_config
    @names_config = ZhangmenrenConfig.instance.name_config
  end

  def show
    @canzhang = Canzhang.find(params[:id])
    #残章，功夫，名称的解析文件。
    @cz_config = ZhangmenrenConfig.instance.canzhang_config
    @gf_config = ZhangmenrenConfig.instance.gongfu_config
    @names_config = ZhangmenrenConfig.instance.name_config
  end

  def edit
    @canzhang = Canzhang.find(params[:id])
    #残章，功夫，名称的解析文件。
    @cz_config = ZhangmenrenConfig.instance.canzhang_config
    @gf_config = ZhangmenrenConfig.instance.gongfu_config
    @names_config = ZhangmenrenConfig.instance.name_config
  end

  def update
    @canzhang = Canzhang.find(params[:id])
    #残章，功夫，名称的解析文件。
    @cz_config = ZhangmenrenConfig.instance.canzhang_config
    @gf_config = ZhangmenrenConfig.instance.gongfu_config
    @names_config = ZhangmenrenConfig.instance.name_config
    number = params[:canzhang][:number]

    re = @canzhang.update_attributes(number: number)
    respond_to do |format|
      if re
        format.html{ redirect_to :action => :show, :id => @canzhang.id}
      else
        format.html{ render(action: :edit)}
      end

    end
  end

  def new
    user = User.find(session[:user_id])
    canzhangs = user.canzhangs
    @canzhang = Canzhang.new
    #残章，功夫，名称的解析文件。
    @cz_config = ZhangmenrenConfig.instance.canzhang_config
    @gf_config = ZhangmenrenConfig.instance.gongfu_config
    @names_config = ZhangmenrenConfig.instance.name_config
    #用户残章的类型列表
    canzhang_types = user.get_user_canzhang_types(session[:user_id])

    #残章类型列表，不包含用户已有的残章
    @cz_type_list = []
    @cz_config.keys.each() do |cz|
      next if canzhang_types.include?(cz)
      @cz_type_list << cz
    end
  end

  def create
    user = User.find(session[:user_id])
    canzhangs = user.canzhangs
    gongfu = params[:gongfu]
    cz_type = params[:cz_type]
    number = params[:canzhang][:number]
    #残章，功夫，名称的解析文件。
    @cz_config = ZhangmenrenConfig.instance.canzhang_config
    @gf_config = ZhangmenrenConfig.instance.gongfu_config
    @names_config = ZhangmenrenConfig.instance.name_config
    #用户拥有的残章的类型列表
    canzhang_types = user.get_user_canzhang_types(session[:user_id])

    #残章类型列表，不包含用户已有的残章
    @cz_type_list = []
    @cz_config.keys.each() do |cz|
      next if canzhang_types.include?(cz)
      @cz_type_list << cz
    end

    @canzhang = Canzhang.new(cz_type: cz_type, number: number, user_id: session[:user_id])
    if cz_type == "没有该功夫的残章类型"
      logger.debug{"cz_type = #{cz_type}"}
      flash[:error] = "用户无该武功的残章。"
      logger.debug{"flash[:error] = #{flash[:error]}"}
      respond_to do |format|
        format.html{render(action: :new)}
      end
    else
      respond_to do |format|
        if @canzhang.save
          format.html { redirect_to(:action => :show, :id => @canzhang.id) }
        else
          format.html { render :action => "new" }
        end
      end
    end
  end

  def delete
    canzhang = Canzhang.find_by_id(params[:id])
    canzhang.destroy unless canzhang.nil?
    redirect_to(action: :index)
  end

  #
  # 获取用户没有的残章名称列表
  #
  def gongfu_names
    #残章，功夫，名称的解析文件。
    @gf_config = ZhangmenrenConfig.instance.gongfu_config
    @gf_cz_config = ZhangmenrenConfig.instance.gongfu_canzhang_config
    @cz_config = ZhangmenrenConfig.instance.canzhang_config
    @names_config = ZhangmenrenConfig.instance.name_config

    @gf_names = []
    @gf_cz_config.keys.each() do |gfcz|
      @gf_names << @names_config[@gf_config[gfcz]["name"]]
    end

    data = @gf_names
    render_result(ResultCode::OK, data)
  end

  #
  # 获取用户没有的残章名称和类型列表
  #
  def canzhang_types
    #残章，功夫，名称的解析文件。
    @gf_config = ZhangmenrenConfig.instance.gongfu_config
    @gf_cz_config = ZhangmenrenConfig.instance.gongfu_canzhang_config
    @cz_config = ZhangmenrenConfig.instance.canzhang_config
    @names_config = ZhangmenrenConfig.instance.name_config
    canzhang_already_has = []
    user = User.find(session[:user_id])
    cz_already_has = user.canzhangs
    cz_already_has.each() do |cz|
      canzhang_already_has << cz.cz_type
    end
    @cz_types = []
    @gf_cz_config.keys.each() do |gfcz|
      @gf_cz_config[gfcz]["canzhangs"].each() do |cz|
        next if canzhang_already_has.include?(cz["id"])
        @cz_types << [@names_config[@gf_config[gfcz]["name"]], cz["id"]]
      end
    end
    data = @cz_types
    render_result(ResultCode::OK, data)
  end
end
