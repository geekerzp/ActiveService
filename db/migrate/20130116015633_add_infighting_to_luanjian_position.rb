class AddInfightingToLuanjianPosition < ActiveRecord::Migration
  def change
    add_column :lunjian_positions, :in_fighting, :boolean
  end
end
