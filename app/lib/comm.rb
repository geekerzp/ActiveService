#encoding:utf-8
#
# 通用函数
#
module Comm
  #
  # 哈希数组根据时间降序排序
  #
  def sort_time_desc(array)
    1.upto(array.length-1) do |i|
      (array.length-i).times do |j|
        if array[j][:time] < array[j+1][:time]
          array[j],array[j+1] = array[j+1],array[j]
        end
      end
    end
    array
  end


  #
  # 根据配置概率构建概率数组,根据概率随机选择配置项，返回其索引
  #
  def random_config(config_file)
    tmp = 0
    probability_array = []
    config_file.each() do |k|
      tmp += (k['probability'].to_f * 1000).to_i
      probability_array << tmp
    end
    logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) probability_array #{probability_array.to_json}")

    rand_number = rand(tmp)
    logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) rand_number #{rand_number}")
    probability_array.length.times() do |i|
      if rand_number < probability_array[i]
        logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__})  index #{i}")
        break i
      end
    end
  end

end