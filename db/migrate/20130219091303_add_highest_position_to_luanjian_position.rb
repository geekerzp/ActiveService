class AddHighestPositionToLuanjianPosition < ActiveRecord::Migration
  def change
    add_column :lunjian_positions, :highest_position, :integer, :default => 1
  end
end
