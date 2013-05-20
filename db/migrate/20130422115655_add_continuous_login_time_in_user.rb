class AddContinuousLoginTimeInUser < ActiveRecord::Migration
  def up
    add_column :users, :continuous_login_time, :integer
  end

  def down
    remove_column :users, :continuous_login_time
  end
end
