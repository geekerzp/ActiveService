class Admin::ZhangmenjueController < ApplicationController
  layout 'admin'
  before_filter :validate_login_admin

  def index
    user = User.find(session[:user_id])

    #用户的掌门诀
    @zhangmenjues = user.zhangmenjues.paginate(:page => params[:page])

    #将用户的掌门诀以字典形式存储
    @zhangmenjues_info = {}
    @zhangmenjues.each() do |zhangmenjue|
      @zhangmenjues_info[zhangmenjue.id] = zhangmenjue.get_zhangmenjue_details
    end
  end

  def show
    @zhangmenjue = Zhangmenjue.find(params[:id])
    #将用户的掌门诀以字典形式存储
    @zhangmenjues_info = {}
    @zhangmenjues_info[@zhangmenjue.id] = @zhangmenjue.get_zhangmenjue_details
  end

  def edit
    @zhangmenjue = Zhangmenjue.find(params[:id])

    #将掌门诀以字典形式存储
    @zhangmenjues_info = {}
    @zhangmenjues_info[@zhangmenjue.id] = @zhangmenjue.get_zhangmenjue_details
  end

  def update
    @zhangmenjue = Zhangmenjue.find(params[:id])
    #将用户的掌门诀以字典形式存储
    @zhangmenjues_info = {}
    @zhangmenjues_info[@zhangmenjue.id] = @zhangmenjue.get_zhangmenjue_details

    level = params[:zhangmenjue][:level]
    poli = params[:zhangmenjue][:poli]
    score = params[:zhangmenjue][:score]

    re = @zhangmenjue.update_attributes(level: level, poli: poli, score: score)

    respond_to do |format|
      if re
        format.html{ redirect_to :action => :show, :id => @zhangmenjue.id}
      else
        format.html{ render :action => :edit}
      end
    end
  end

  def delete
    zhangmenjue = Zhangmenjue.find_by_id(params[:id])
    zhangmenjue.destroy unless zhangmenjue.nil?
    redirect_to(action: :index)
  end

  def new
    #@zhangmenjue = Zhangmenjue.new
  end

  def create
    #user_id = session[:user_id]
    #z_type = params[:zhangmenjue][:z_type]
    #level = params[:zhangmenjue][:level]
    #poli = params[:zhangmenjue][:poli]
    #score = params[:zhangmenjue][:score]
    #@zhangmenjue = Zhangmenjue.new(z_type: z_type, level: level, poli: poli, score: score, user_id: user_id)
    #respond_to do |format|
    #  if @zhangmenjue.save
    #    format.html { redirect_to(:action => :show, :id => @zhangmenjue.id) }
    #  else
    #    format.html { render :action => "new" }
    #  end
    #end
  end
end
