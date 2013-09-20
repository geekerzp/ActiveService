#
#定义返回结果数据结构
#
class Result
  attr_accessor :code, :data

  def initialize
    @code = ResultCode::ERROR
  end
end