class AddDirectionStepToUser < ActiveRecord::Migration
  def change
    add_column :users, :direction_step, :integer
  end
end
