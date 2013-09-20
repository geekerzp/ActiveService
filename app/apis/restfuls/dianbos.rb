#encoding: utf-8
module Restfuls
	class Dianbos < Grape::API
	  #version 'v1', :using => :path
	  format :json

	  helpers DianboHelper

	  resource 'dianbo' do
	  	desc '创建一个新的奇遇点拨接口'
	  	params do
	  		requires :session_key,type: String,desc: '会话key'
	  		requires :type,type: Integer,desc: '点拨类型id'
	  	end
	    get "/create_new_dianbo" do
	    	create_new_dianbo
	    end
      post "/create_new_dianbo" do
        create_new_dianbo
      end

	    desc '使用点拨接口'
	    params do
	    	requires :session_key,type: String,desc: '会话key'
	  		requires :id,type: Integer,desc: '点拨id'
	    end
	    get "/use_dianbo" do
	      use_dianbo
      end
      post "/use_dianbo" do
        use_dianbo
      end

	    desc '获取未使用点拨接口'
	    params do
	    	requires :session_key,type: String,desc: '会话key'
	    end
	    get "/get_unused_dianbos" do
	      get_unused_dianbos
      end
      post "/get_unused_dianbos" do
        get_unused_dianbos
      end

	    desc '删除点拨接口'
	    params do
	    	requires :session_key,type: String,desc: '会话key'
	  		requires :id,type: Integer,desc: '点拨id'
	    end
	    get "/delete_dianbo" do
	    	delete_dianbo
      end
      post "/delete_dianbo" do
        delete_dianbo
      end
	  end
	end
end 
