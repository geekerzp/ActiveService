class TeamMember < ActiveRecord::Base
  attr_accessible :user_id, :disciple_id, :position

  belongs_to :user
  belongs_to :disciple

  validates :user_id, :disciple_id, :position, :presence => true
  validates :user_id, :disciple_id, :position, :numericality => { :greater_than_or_equal_to => -1,
                                                                  :only_integer => true}

  #
  # 更新阵容
  #
  # @param [User] user  用户
  # @param [Array] team 新阵容
  def self.update_team(user, team)
    team = team.map() {|id| id.to_i}
    err_msg = ""
    # 检查传过来的弟子id是否都属于当前用户
    team.each() do |id|
      return false, "disciple #{id} does not exist." unless Disciple.exists?(id: id, user_id: user.id)
    end
    user.team_members.destroy_all # 删除旧阵容
    team.each() do |disciple_id|
      tm = TeamMember.new
      tm.user_id = user.id
      tm.disciple_id = disciple_id
      tm.position = team.index(disciple_id)
      tm.save
    end
    return err_msg.length <= 0, err_msg
  end
  def self.get_team(user)
    team = []
    user.team_members.each do|t|
      team << t.disciple_id
    end
    team
  end
end
