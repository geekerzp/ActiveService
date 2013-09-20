#
# 主文件（接口初始化）
# 

# 加载entities.rb, helpers.rb, patch.rb
Dir[File.dirname(__FILE__) + '/*.rb'].each {|i| require i }             
#加载validations目录下的文件
Dir[File.dirname(__FILE__) + '/validations/*.rb'].each {|v| require v } 
# 加载model
Dir[File.dirname(__FILE__) + '/../models/*.rb'].each {|m| require m } 
# 加载helper
Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each {|h| require h } 
# 加载routes
Dir[File.dirname(__FILE__) + '/restfuls/*.rb'].each {|r| require r }  

module Application
  class Api < Grape::API
    format :json        # 数据格式为json
    helpers ApiHelpers  # 公共助手方法

    # 拦截错误信息，显示简单错误信息，不显示调用堆栈
    #rescue_from :all do |e|
    #  Rack::Response.new([e.message], 500, { "Content-type" => "application/json" }).finish
    #end 

    # 挂载接口
    mount Restfuls::Users
    mount Restfuls::Market
    mount Restfuls::Recharges
    mount Restfuls::Qiyu
    mount Restfuls::Systems
    mount Restfuls::Teams
    mount Restfuls::Dianbos
    mount Restfuls::Canzhangs
    mount Restfuls::Friends
    mount Restfuls::Handbooks
    mount Restfuls::Jianghus
    mount Restfuls::Kapais
    mount Restfuls::Lunjians
  end 
end 
