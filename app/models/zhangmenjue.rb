# vi: set fileencoding=utf-8 :
require 'second_level_cache/second_level_cache'

class Zhangmenjue < ActiveRecord::Base
  acts_as_cached(version: 1, expires_in: 1.week)  # 开启二级缓存

  attr_accessible :level, :poli, :score, :user_id, :z_type

  belongs_to :user

  validates :level, :poli, :score, :user_id, :z_type, :presence => true
  validates :level, :poli, :score, :user_id, :numericality => {:greater_than_or_equal_to => 0, :only_integer => true}
  validates :z_type, :numericality => {:greater_than_or_equal_to => 1,
                                       :less_than_or_equal_to => 4,
                                       :only_integer => true}

  # 掌门诀类型
  ZHANGMENJUE_TYPE_ATTACK   = 1 # 攻
  ZHANGMENJUE_TYPE_DEFEND   = 2 # 防
  ZHANGMENJUE_TYPE_BLOOD    = 3 # 血
  ZHANGMENJUE_TYPE_INTERNAL = 4 # 内

  ZHANGMENJUE_TYPES = [ZHANGMENJUE_TYPE_ATTACK, ZHANGMENJUE_TYPE_BLOOD,
                       ZHANGMENJUE_TYPE_DEFEND, ZHANGMENJUE_TYPE_INTERNAL]
  #
  # 将信息转化为字典形式
  #
  def to_dictionary()
    re = {}
    re[:id] = self.id
    re[:level] = self.level
    re[:poli] = self.poli
    re[:score] = self.score
    re[:type] = self.z_type
    re
  end

  #
  # 获取掌门诀的详情。
  #
  def get_zhangmenjue_details
    re = {}
    re[:id] = self.id
    re[:level] = self.level
    re[:poli] = self.poli
    re[:score] = self.score
    re[:type] = self.z_type
    if self.z_type == 1
      type = "攻"
    end
    if self.z_type == 2
      type = "防"
    end
    if self.z_type == 3
      type = "血"
    end
    if self.z_type == 4
      type = "内"
    end
    re[:zhangmenjue_type] = type
    re
  end

  #
  # 更新掌门诀
  #
  # @param [User] user              当前用户
  # @param [Array] zhangmenjue_arry 掌门诀信息数组
  def self.update_zhangmenjues(user, zhangmenjue_arry)
    err_msg = ""
    zhangmenjue_arry.each() do |zmj_info|
      if zmj_info[:type].nil? || ZHANGMENJUE_TYPES.find_index(zmj_info[:type].to_i).nil?
        return false, "No such zhangmenjue type #{zmj_info[:type]}"
      end
      zhangmenjue = Zhangmenjue.find_by_user_id_and_z_type(user.id, zmj_info[:type])
      if zhangmenjue.nil?
        # 用户没有这种类型的掌门诀，创建一个。
        zhangmenjue = Zhangmenjue.new(user_id: user.id, z_type: zmj_info[:type])
      end
      zhangmenjue.level = (zmj_info[:level] || 0).to_i
      zhangmenjue.poli = (zmj_info[:poli] || 0).to_i
      zhangmenjue.score = (zmj_info[:score] || 0).to_i
      unless zhangmenjue.save
        err_msg << zhangmenjue.errors.full_messages.join('; ')
        logger.error("### save zhangmenjue error. #{err_msg}")
        return false, err_msg
      end
    end
    return true, ''
  end
end
