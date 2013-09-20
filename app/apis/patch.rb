# 
# 给grape打补丁（修改源码自用）
#

# 
# 修改Logger类，在production模式禁止debug输出
#
class Logger 
  alias_method :old_debug, :debug
  def debug(*args, &block)
    return if Goliath.env? "production"
    old_debug(*args, &block)
  end 
end 
