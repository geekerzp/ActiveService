class AddUpgradeRewardInUser < ActiveRecord::Migration
  def up
    add_column :users, :upgrade_3_reward, :integer
    add_column :users, :upgrade_5_reward, :integer
    add_column :users, :upgrade_10_reward, :integer
    add_column :users, :upgrade_15_reward, :integer
  end

  def down
    remove_column :users, :upgrade_3_reward
    remove_column :users, :upgrade_5_reward
    remove_column :users, :upgrade_10_reward
    remove_column :users, :upgrade_15_reward
  end
end
