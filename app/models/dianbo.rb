# vi: set fileencoding=utf-8 :
require 'second_level_cache/second_level_cache'

class Dianbo < ActiveRecord::Base
  acts_as_cached(version: 1, expires_in: 1.week)  # 开启二级缓存

  attr_accessible :dianbo_type, :user_id, :server_time

  belongs_to :user

  validates :dianbo_type, :presence => true
  validates :dianbo_type, :numericality =>{:only_integer => true, :greater_than_or_equal_to => 1}

  #点拨的5中类型。
  DianboTypeOne     = 1
  DianboTypeTwo     = 2
  DianboTypeThree   = 3
  DianboTypeFour    = 4
  DianboTypeFive    = 5

  #
  # 点拨类型列表
  #
  def self.get_types_list
    type_list = [Dianbo::DianboTypeOne, Dianbo::DianboTypeTwo, Dianbo::DianboTypeThree,
                 Dianbo::DianboTypeFour, Dianbo::DianboTypeFive]

    type_list
  end

  ##
  ## 获取用户女儿红的数量
  ##
  #def get_nverhong_number
  #  @names_config = ZhangmenrenConfig.instance.name_config
  #  goods = self.user_goodss
  #
  #  nverhong_number = 0
  #  goods.each() do |g|
  #    if @names_config[g.g_type] == "女儿红"
  #      nverhong_number = g.number
  #    end
  #  end
  #  nverhong_number
  #end
  #
  ##
  ## 获取用户上阵弟子的平均等级。
  ##
  #def get_average()
  #
  #end

  #
  # 获取点拨详情，字典数据。
  #
  def to_dictionary
    dianbo_info = {}
    dianbo_info[:id] = self.id
    dianbo_info[:type] = self.dianbo_type
    dianbo_info[:server_time] = self.server_time
    if self.created_at.nil?
      dianbo_info[:created_at] = URI.encode('')
    else
      dianbo_info[:created_at] = URI.encode(self.created_at.strftime('%Y-%m-%d %H:%M:%S')||'')
    end
    dianbo_info
  end

  #
  # 添加点拨
  #
  def self.add_new_dianbo(user, type, server_time)
    dianbo = Dianbo.new(dianbo_type: type, user_id:user.id, server_time: server_time)

    if dianbo.save
      dianbo_info = dianbo.to_dictionary
      return true, dianbo_info
    else
      return false, ''
    end
  end

  #
  # 使用点拨
  #
  def self.use(id)
    dianbo = Dianbo.find_by_id(id)
    if dianbo.nil?
      return false
    end

    dianbo.destroy
  end

  #
  # 获取点拨的列表
  #
  def self.get_user_dianbos(user, server_time)
    user_dianbos = user.dianbos
    dianbo_infos = []
    unless user_dianbos.nil?
      user_dianbos.each() do |d|
        d.update_attributes(server_time: server_time)
        dianbo_infos << d.to_dictionary
      end
    end
    dianbo_infos
  end

  #
  # 删除点拨
  #
  def self.delete_dianbo(id)
    dianbo = Dianbo.find_by_id(id)
    dianbo.destroy unless dianbo.nil?
  end
end
