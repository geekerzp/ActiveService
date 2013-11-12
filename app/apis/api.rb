module Application
  class Api < Grape::API
    format :json
    helpers ApiHelpers

    # 拦截错误信息，显示简单错误信息，不显示调用堆栈
    #rescue_from :all do |e|
    #  Rack::Response.new([e.message], 500, { "Content-type" => "application/json" }).finish
    #end

    # 挂载接口
    mount Restfuls::Users
  end
end
