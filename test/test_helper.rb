ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  #
  # 测试接口通用函数
  #
  # @param [String] interface_name 接口名称
  # @param [Dir] params 接口参数
  # @param [Integer] result 期待的结果
  # @return [JSON] 接口返回的JSON数据
  def test_interface(interface_name, params, result)
    post(interface_name, params)
    assert_response :success
    resp = JSON.parse(@response.body)
    puts "===== [post] **#{interface_name}** ===== #{params.to_s} -->:"
    puts URI.decode(JSON.pretty_generate(resp).to_s)
    puts ''
    assert_equal(result, resp["code"], "The result is wrong! body: #{resp.to_s}")
    resp
  end
end
