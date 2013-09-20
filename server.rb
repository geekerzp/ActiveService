#
# goliath api服务器启动文件（程序初始化）
#

# 加载核心模块
require './core/gga'

# 加载Goliath
require 'goliath'

class ApplicationApi < Goliath::API
  def response(env)
    ::Application::Api.call(env)
  end
end
