######################
#    一些公用方法    #
######################

module ApiHelpers
  #
  # 获取logger
  #
  def logger
    GGA.logger
  end

  #
  # 认证用户
  #
  def authenticate!
    error!('401 Unauthorized', 401) unless current_user
  end

  #
  # 当前用户
  #
  def current_user
    @current_user ||= User.find_by_session_key(params[:session_key])
  end
end
