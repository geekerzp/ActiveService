#coding : utf-8
class Result
  attr_accessor :code, :data

  def initialize
    @code = ResultCode::ERROR
  end
end