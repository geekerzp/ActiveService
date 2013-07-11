class AddPowerTimeAndSpriteTimeToUser < ActiveRecord::Migration
  def change
    add_column :users,:power_time, :datetime
    add_column :users,:sprite_time, :datetime
  end
end
