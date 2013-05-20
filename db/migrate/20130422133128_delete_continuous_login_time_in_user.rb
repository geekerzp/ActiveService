class DeleteContinuousLoginTimeInUser < ActiveRecord::Migration
  def up
    remove_column :users, :continuous_login_time
  end

  def down
    add_column :users, :continuous_login_time, :integer
  end
end
