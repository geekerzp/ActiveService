class ChangeRewardType < ActiveRecord::Migration
  def up
    add_column :continuous_login_rewards, :reward_1_id, :string
    add_column :continuous_login_rewards, :reward_2_id, :string
    add_column :continuous_login_rewards, :reward_3_id, :string
    change_column :continuous_login_rewards, :reward_1_type, :integer
    change_column :continuous_login_rewards, :reward_2_type, :integer
    change_column :continuous_login_rewards, :reward_3_type, :integer
  end

  def down
    remove_column :continuous_login_rewards, :reward_1_id
    remove_column :continuous_login_rewards, :reward_2_id
    remove_column :continuous_login_rewards, :reward_3_id
    change_column :continuous_login_rewards, :reward_1_type, :string
    change_column :continuous_login_rewards, :reward_2_type, :string
    change_column :continuous_login_rewards, :reward_3_type, :string
  end
end
