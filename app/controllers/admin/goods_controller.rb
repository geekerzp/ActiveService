class Admin::GoodsController < ApplicationController
  layout 'admin'
  before_filter :validate_login_admin

  def index
    user = User.find(session[:user_id])
    #用户的物品。
    @goods = user.user_goodss.paginate(:page => params[:page])

    #解析物品与名称
    @goods_config = ZhangmenrenConfig.instance.goods_config
    @names_config = ZhangmenrenConfig.instance.name_config
    @normal_bag_config = ZhangmenrenConfig.instance.normal_bag_config
    @gift_bag_config = ZhangmenrenConfig.instance.gift_bag_config
  end

  def new
    @goods = UserGoods.new
    #解析物品与名称
    @goods_config = ZhangmenrenConfig.instance.goods_config
    @names_config = ZhangmenrenConfig.instance.name_config
    user = User.find(session[:user_id])

    #找到用户已有的物品类型。
    user_goods_list = user.get_user_goods(session[:user_id])

    #找到用户可以添加的物品类型，排除用户已有的物品。
    @goods_list = []
    @goods_config.keys.each() do |g|
      next if user_goods_list.include?(g)
      @goods_list << g
    end
  end

  def create
    g_name = params[:goods][:g_type]
    number = params[:goods][:number]

    #解析物品与名称
    @goods_config = ZhangmenrenConfig.instance.goods_config
    @names_config = ZhangmenrenConfig.instance.name_config
    user = User.find(session[:user_id])

    #找到用户已有的物品类型。
    user_goods_list = user.get_user_goods(session[:user_id])

    #找到用户可以添加的物品类型，排除用户已有的物品。
    @goods_list = []
    @goods_config.keys.each() do |g|
      next if user_goods_list.include?(g)
      @goods_list << g
    end
    @goods = UserGoods.new
    #得到物品的类型。
    g_type = @goods.change_name_to_type(g_name)
    @goods = UserGoods.new(g_type: g_type, number: number, user_id: session[:user_id])
    respond_to do |format|
      if @goods.save
        format.html { redirect_to(:action => :show, :id => @goods.id) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def show
    @goods = UserGoods.find(params[:id])

    #解析物品与名称
    @goods_config = ZhangmenrenConfig.instance.goods_config
    @names_config = ZhangmenrenConfig.instance.name_config
  end

  def delete
    goods = UserGoods.find_by_id(params[:id])
    goods.destroy unless goods.nil?
    redirect_to(action: :index)
  end

  def edit
    @goods = UserGoods.find(params[:id])

    #名称解析。
    @names_config = ZhangmenrenConfig.instance.name_config
  end

  def update
    @goods = UserGoods.find(params[:id])
    number = params[:goods][:number]
    @goods.update_attributes(number: number)

    #名称解析。
    @names_config = ZhangmenrenConfig.instance.name_config

    respond_to do |format|
      format.html{ redirect_to :action => :show, :id => @goods.id}
    end
  end
end
