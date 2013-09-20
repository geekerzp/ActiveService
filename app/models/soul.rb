# vi: set fileencoding=utf-8 :
require 'second_level_cache/second_level_cache'

class Soul < ActiveRecord::Base
  acts_as_cached(version: 1, expires_in: 1.week)  # 开启二级缓存

  attr_accessible :s_type, :number, :potential, :user_id

  belongs_to :user
  belongs_to :disciple

  validates :s_type, :number, :potential, :user_id, :presence => true
  validates :number, :potential, :user_id, :numericality => {:greater_than_or_equal_to => 0, :only_integer => true}


  #
  # 将信息转化为字典形式
  #
  def to_dictionary()
    re = {}
    re[:id] = self.id
    re[:potential] = self.potential
    re[:number] = self.number
    re[:type] = URI.encode(self.s_type || '')
    re
  end

  #
  # 更新魂魄
  #
  # @param [User] user
  # @param [Array] souls_array
  def self.update_souls(user, souls_array)
    err_msg = ""
    souls_array.each() do |soul_info|
      soul = Soul.find_by_s_type_and_user_id(soul_info[:type] || '', user.id)
      if soul.nil?
        # 用户之前没有这种类型的魂魄，创建一条记录。
        soul = Soul.new(user_id: user.id, s_type: soul_info[:type] || '')
      end
      soul.potential = (soul_info[:potential] || 0).to_i
      soul.number = (soul_info[:number] || 0).to_i
      unless soul.save
        err_msg << soul.errors.full_messages.join('; ')
        logger.debug("### #{__method__},(#{__FILE__}, #{__LINE__}) save soul error. #{err_msg}")
        return false, err_msg
      end
      # 删除剩余数为0的魂魄
      soul.destroy if soul.number == 0
    end
    return true, ''
  end

  #
  # 魂魄突破为弟子
  #
  # @param [User] user      当前用户
  # @param [String] type    魂魄类型
  # @param [Integer] num    魂魄数量
  # @return [Boolean]       是否成功
  # @return [Disciple]      成功时返回新创建的弟子
  # @return [String]        失败时返回错误信息
  def update_to_disciple(user, type, num)
    err_msg = ""
    if self.number < num
      err_msg << "no enough souls. We have #{self.number} souls, but we need #{num}."
      logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) #{err_msg}")
      return false, err_msg
    end

    disciple = Disciple.create_disciple(user, type)
    if disciple.nil?
      return false, "### #{__method__},(#{__FILE__}, #{__LINE__}) no such disciple #{type}"
    end
    self.number -= num
    unless self.save && disciple.save
      err_msg << self.errors.full_messages.join('; ')
      err_msg << disciple.errors.full_messages.join('; ')
      logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) #{err_msg}")
      return false, err_msg
    end

    return true, disciple
  end

  #
  # 魂魄突破
  #
  # @param [User] user        当前用户
  # @param [Integer] num      需要的魂魄数量
  # @param [Integer] potential可以获得的潜力
  # @return [Boolean]         是否成功
  # @return [Disciple]        成功时返回新创建的弟子
  # @return [String]          失败时返回错误信息
  def break(user, num, potential)
    err_msg = ""
    if self.number < num
      err_msg << "no enough souls. We have #{self.number} souls, but we need #{num}."
      logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) #{err_msg}")
      return false, err_msg
    end

    disciple = Disciple.find_by_d_type_and_user_id(self.s_type, user.id)
    if disciple.nil?
      err_msg << "no such disciple. #{self.s_type}. Can not break."
      logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) #{err_msg}")
      return false, err_msg
    end

    self.number -= num
    disciple.potential += potential
    disciple.break_time += 1
    unless self.save && disciple.save
      err_msg << self.errors.full_messages.join('; ')
      err_msg << disciple.errors.full_messages.join('; ')
      logger.error("### #{__method__},(#{__FILE__}, #{__LINE__}) #{err_msg}")
      return false, err_msg
    end
    return true, disciple
  end
end
