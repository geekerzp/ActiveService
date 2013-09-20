#coding : utf-8
# 一些公用方法

module ApiHelpers
  #
  # 获取logger
  #
  def logger 
    GGA.logger
  end

  #
  # 获取参数并解码
  #
  def get_params(params, key)
    value = params[key]
    value ||= ''
    value.gsub!('+', '%20')
    URI.decode(value)
  end

  #
  # 验证session key
  #
  # @param [Object] session_key session key
  #
  def validate_session_key(session_key)
    user = User.find_by_session_key(session_key)
    if user.nil?
      render_result(ResultCode::INVALID_SESSION_KEY, {err_msg: URI.encode('invalid session key')})
      return false, nil
    end
    return true, user
  end

  #
  # 发送结果
  #
  # @param [ResultCode] code  结果码
  # @param [Hash] data        数据
  def render_result(code, data)
    result = Result.new
    result.code = code
    result.data = data
    result
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
