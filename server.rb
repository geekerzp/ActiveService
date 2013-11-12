###########################################
# goliath api服务器启动文件（程序初始化） #
###########################################

# Load core module
require ::File.expand_path('../core/gga', __FILE__)

# Load Goliath
require 'goliath'

class ApplicationApi < Goliath::API
  def response(env)
    ::Application::Api.call(env)
  end
end
