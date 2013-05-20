class UserGoods < ActiveRecord::Base
  attr_accessible :g_type, :number, :user_id

  belongs_to :user

  validates :user_id, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
  validates :g_type, :presence => true
  validates :g_type, :length => {:minimum => 1, :maximum => 250}
  validates :number, :numericality => {:greater_than_or_equal_to => 1}

  #
  # 将信息转化为字典形式
  #
  def to_dictionary()
    re = {}
    re[:id] = self.id
    re[:number] = self.number
    re[:type] = self.g_type
    re
  end

  #
  # 更新用户物品
  #
  # @param [User] user    当前用户
  # @param [Array] goods  物品列表
  def self.update_goods(user, goods)
    goods.each() do |g|
      number = (g[:number] || 0).to_i
      type = (g[:type] || '').to_s
      ug = UserGoods.find_by_user_id_and_g_type(user.id, type)
      if ug.nil?
        ug = UserGoods.new(user_id: user.id, g_type: type)
      end
      ug.number = number
      ug.save
    end

    # 删除参数goods中没有的道具，保持数据一致性
    user.user_goodss.each() do |g|
      if (goods.find() {|gd| gd[:type] == g.g_type}).nil?
        g.destroy
      end
    end
    true
  end

  #
  # 物品类型与名称的装换
  #
  def change_name_to_type(good_name)
    @names_config = ZhangmenrenConfig.instance.name_config
    g_type = ''
    @names_config.keys.each() do |n|
      if @names_config[n] == good_name
        g_type = n
      end
    end
    g_type
  end
end
