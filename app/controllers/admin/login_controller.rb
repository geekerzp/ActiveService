#encoding: utf-8
class Admin::LoginController < ApplicationController
  layout false

  #
  # 登录
  #
  def login
    username = get_params(params, :username)
    password = get_params(params, :password)
    if password.length <= 0 || username.length <= 0
      respond_to do |format|
        format.html
      end
      return
    end

    session_key, user = Admins.login(username, password)

    if user.nil?
      flash[:error] = "用户名或密码错误"
      respond_to do |format|
        format.html
      end
      return
    end
    logger.debug("(#{__FILE__}, #{__LINE__}, #{__method__}) login success. session key #{session_key}")
    session[:session_key] = session_key
    redirect_to :controller => '/admin/user', :action => 'index'
  end

  #
  # 登出
  #
  def logout
    session_key = session[:session_key]
    if session_key.nil? or session_key.length <= 0
      redirect_to :action => 'login'
      return
    end

    Admins.logout(session_key)
    redirect_to :action => 'login'
  end
end
