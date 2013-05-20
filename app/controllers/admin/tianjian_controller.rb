class Admin::TianjianController < ApplicationController
  layout 'admin'
  before_filter :validate_login_admin

  def index
    user = User.find(session[:user_id])
    @tianjian = user.user_goodss
  end

  def show
    @tianjian = UserGoods.find(params[:id])
  end

  def edit
    @tianjian = UserGoods.find(params[:id])
  end

  def update
    @tianjian = UserGoods.find(params[:id])
    number = params[:tianjian][:number]
    @tianjian.update_attributes(number: number)

    respond_to do |format|
      format.html{ redirect_to :action => :show, :id => @tianjian.id}
    end
  end

  def delete
    tj = UserGoods.find_by_id(params[:id])
    tj.destroy unless tj.nil?
    redirect_to(action: :index)
  end
end
