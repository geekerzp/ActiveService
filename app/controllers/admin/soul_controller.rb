class Admin::SoulController < ApplicationController
  layout 'admin'
  before_filter :validate_login_admin
  
  def index
  end

  def new
    @soul = Soul.new
    #弟子，名称的解析。
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config
    user = User.find(session[:user_id])

    #获得用户已有的魂魄类型
    souls_types = user.get_user_souls(session[:user_id])

    #获得用户可添加的魂魄类型，排除已有的魂魄
    #@s_type_list = []
    #@disciple_config.keys.each() do |d|
    #  next if souls_types.include?(d)
    #  @s_type_list << d
    #end
    #获得用户已有的魂魄类型
    @s_types = Soul.where(["user_id = ?", session[:user_id]]).select(:s_type).uniq
    st = []
    @s_types.each()do |s|
      st << s.s_type
    end
    @souls = []
    #获得用户可添加的魂魄类型，排除已有的魂魄
    @disciple_config.keys.each do |d|
      if st.include?(d)
        next
      end
      @souls << @disciple_config[d]["name"]
    end
  end

  def create
    #弟子，名称的解析。
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config
    user_id = session[:user_id]
    potential = params[:soul][:potential]
    number = params[:soul][:number]
    name = params[:soul][:s_type]
    user = User.find(session[:user_id])

    #获得用户已有的魂魄类型
    @s_types = Soul.where(["user_id = ?", session[:user_id]]).select(:s_type).uniq
    st = []
    @s_types.each()do |s|
      st << s.s_type
    end
    @souls = []
    @disciple_config.keys.each do |d|
      if st.include?(d)
          next
      end
    @souls << @disciple_config[d]["name"]
    end

    d_name = ''
    @names_config.keys.each() do |n|
      if @names_config[n] == name
        if n.gsub(/name_disciple_/, '').to_i > 5000
          next
        else
          d_name = n
        end
      end
    end

    #找到魂魄的弟子类型
    d_type = ""
    @disciple_config.keys.each() do |d|
      if @disciple_config[d]["name"] == d_name
        d_type = d
      end
    end

    s_type = ''
    @disciple_config.keys.each() do |d|
      if @disciple_config[d]["name"] == 'name_'+d_type
        s_type = d
      end
    end

    @soul = Soul.new(potential: potential, number: number, s_type: s_type, user_id: user_id)
    respond_to do |format|
      if @soul.save
        format.html { redirect_to(:action => :show, :id => @soul.id) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def show
    @soul = Soul.find(params[:id])
    #弟子，名称的解析。
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config
  end

  def edit
    @soul = Soul.find(params[:id])
    #弟子，名称的解析。
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config
  end

  def update
    @soul = Soul.find(params[:id])
    @soul.number = params[:soul][:number]

    #弟子，名称的解析。
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config
    respond_to do |format|
      if @soul.save
        format.html {redirect_to(action: :show, id: @soul.id)}
      else
        format.html {render(action: :edit)}
      end
    end
  end

  def delete
    soul = Soul.find(params[:id])
    soul.destroy unless soul.nil?
    redirect_to(controller: :user, action: :show, id: session[:user_id])
  end
end
