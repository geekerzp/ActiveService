class ApplicationController < ActionController::Base
  protect_from_forgery

  WillPaginate.per_page = 15

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
  # 验证管理员session key
  #
  def validate_login_admin
    logger.debug("session key #{session[:session_key]}")
    if session[:session_key].nil?
      redirect_to :controller => 'admin/login', :action => 'login'
      return
    end
    @current_user = Admins.find_by_session_key(session[:session_key])
    if @current_user.nil?
      redirect_to :controller => 'admin/login', :action => 'login'
    end
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
    render(json: result)
  end

  #
  # 输出每次接口调用时，内存使用情况
  # 使用下面的命令查看结果。
  #
  # grep "CONSUME MEMORY" development.log | grep -v "CONSUME MEMORY: 0" |   grep -v "CONSUME MEMORY: -"
  # |  awk '{print $3 "\t" $6 "\t" $8 }' | sort -r -n |  head -n 500 > memory.log ; cat memory.log
  #
  around_filter :record_memory
  def record_memory
    unless File.exists?("/proc/#{Process.pid}/status")
      yield
      return
    end

    process_status = []
    File.open("/proc/#{Process.pid}/status")do |f|
      str = f.gets
      while !str.nil?
        process_status << str
        str = f.gets
      end
    end
    rss_info = process_status.find() {|s| !s.index('VmRSS').nil?}
    rss_before_action = rss_info.split[1].to_i

    yield

    process_status = []
    File.open("/proc/#{Process.pid}/status")do |f|
      str = f.gets
      while !str.nil?
        process_status << str
        str = f.gets
      end
    end
    rss_info = process_status.find() {|s| !s.index('VmRSS').nil?}
    rss_after_action = rss_info.split[1].to_i
    logger.info("CONSUME MEMORY: #{rss_after_action - rss_before_action} \KB\tNow: #{rss_after_action} KB\t#{request.url}")
  end

end
